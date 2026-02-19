import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Background FCM handler (top-level, required by firebase_messaging)
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.notification?.title}');
}

// ─────────────────────────────────────────────────────────────────────────────
// Android notification channel
// ─────────────────────────────────────────────────────────────────────────────
const AndroidNotificationChannel androidChannel = AndroidNotificationChannel(
  'chat_messages_channel',
  'Chat Messages',
  description: 'New chat message notifications',
  importance: Importance.high,
  playSound: true,
  enableVibration: true,
);

// ─────────────────────────────────────────────────────────────────────────────
// Notification Service
// Matches your Firestore structure:
//   conversations/{conversationId}/messages/{messageId}
//   fields: senderId, receiverId, content, timestamp
// ─────────────────────────────────────────────────────────────────────────────
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Active Firestore listeners — cancelled on logout
  final List<StreamSubscription> _listeners = [];

  // Already-notified message IDs — avoids duplicate notifications
  final Set<String> _notifiedIds = {};

  // ── Initialize ─────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    await _requestPermission();
    await _initLocalNotifications();

    // Register background FCM handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle FCM messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_showFcmNotification);

    // Save device token to Firestore
    await saveFcmToken();

    // Refresh token when it changes
    _fcm.onTokenRefresh.listen(_updateTokenInFirestore);
  }

  // ── Request permission (iOS + Android 13+) ─────────────────────────────────
  Future<void> _requestPermission() async {
    final NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification permission: ${settings.authorizationStatus}');
  }

  // ── Set up flutter_local_notifications ────────────────────────────────────
  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);

    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  // ── Start listening to all conversations for this user ────────────────────
  // Call this in HomeScreen.initState()
  Future<void> startListeningForMessages() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    // Stop any existing listeners first
    await stopListeningForMessages();

    try {
      // Your conversations collection uses 'participants' array
      // We listen to ALL conversations then filter by receiverId in message
      final QuerySnapshot conversations = await _firestore
          .collection('conversations')
          .where('participants', arrayContains: user.uid)
          .get();

      for (final doc in conversations.docs) {
        _listenToConversation(doc.id, user.uid);
      }

      debugPrint(
        'NotificationService: Listening to ${conversations.docs.length}'
        ' conversations',
      );
    } catch (e) {
      debugPrint('NotificationService: Failed to start listeners: $e');
    }
  }

  // ── Listen to a single conversation for new incoming messages ─────────────
  void _listenToConversation(String conversationId, String currentUserId) {
    final subscription = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1) // Only watch the very latest message
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isEmpty) return;

      final doc = snapshot.docs.first;
      final String messageId = doc.id;

      // Skip if already notified
      if (_notifiedIds.contains(messageId)) return;

      final Map<String, dynamic> data = doc.data();

      // Your field names from chat_service.dart:
      final String senderId = data['senderId'] ?? '';
      final String receiverId = data['receiverId'] ?? '';

      // ✅ 'content' is your message text field (not 'text')
      final String messageText = data['content'] ?? 'New message';
      final Timestamp? timestamp = data['timestamp'] as Timestamp?;

      // Only notify if this message is FOR the current user
      if (receiverId != currentUserId) {
        _notifiedIds.add(messageId);
        return;
      }

      // Only notify for recent messages (within last 10 seconds)
      // Prevents showing old messages as notifications on app start
      if (timestamp != null) {
        final int secondsAgo =
            DateTime.now().difference(timestamp.toDate()).inSeconds;
        if (secondsAgo > 10) {
          _notifiedIds.add(messageId);
          return;
        }
      }

      // Mark as notified before async work to avoid race conditions
      _notifiedIds.add(messageId);

      // Get sender display name from users collection
      String senderName = 'New Message';
      try {
        final senderDoc =
            await _firestore.collection('users').doc(senderId).get();
        if (senderDoc.exists) {
          // Try displayName first, then name, then email
          senderName = senderDoc.data()?['displayName'] ??
              senderDoc.data()?['name'] ??
              senderDoc.data()?['email'] ??
              'New Message';
        }
      } catch (e) {
        debugPrint('NotificationService: Could not get sender name: $e');
      }

      // Show the notification banner
      await _displayNotification(
        id: messageId.hashCode,
        title: senderName,
        body: messageText,
        payload: conversationId,
      );

      debugPrint(
        'NotificationService: Showed notification from $senderName'
        ' in $conversationId',
      );
    });

    _listeners.add(subscription);
  }

  // ── Display a local notification banner ───────────────────────────────────
  Future<void> _displayNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannel.id,
          androidChannel.name,
          channelDescription: androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  // ── Show notification from FCM RemoteMessage ───────────────────────────────
  Future<void> _showFcmNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _displayNotification(
      id: notification.hashCode,
      title: notification.title ?? 'New Message',
      body: notification.body ?? '',
      payload: message.data['conversationId'],
    );
  }

  // ── Save FCM token to Firestore users collection ───────────────────────────
  Future<void> saveFcmToken() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return;
      final String? token = await _fcm.getToken();
      if (token == null) return;
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
      });
      debugPrint('NotificationService: FCM token saved');
    } catch (e) {
      debugPrint('NotificationService: Failed to save FCM token: $e');
    }
  }

  // ── Update FCM token when it refreshes ────────────────────────────────────
  Future<void> _updateTokenInFirestore(String newToken) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return;
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': newToken});
    } catch (e) {
      debugPrint('NotificationService: Failed to update FCM token: $e');
    }
  }

  // ── Stop all listeners — call on logout ───────────────────────────────────
  Future<void> stopListeningForMessages() async {
    for (final sub in _listeners) {
      await sub.cancel();
    }
    _listeners.clear();
    _notifiedIds.clear();
    debugPrint('NotificationService: Stopped all listeners');
  }

  // ── Delete FCM token on logout ─────────────────────────────────────────────
  Future<void> deleteToken() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return;
      await _fcm.deleteToken();
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': FieldValue.delete(),
      });
      debugPrint('NotificationService: FCM token deleted');
    } catch (e) {
      debugPrint('NotificationService: Failed to delete token: $e');
    }
  }
}