import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../utils/constants.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream ya kuvuta users wote kutoka Firestore kwa realtime
  Stream<List<ChatModel>> getUsers() {
    return _firestore
        .collection(kUsersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatModel.fromMap(data, doc.id);
      }).toList();
    });
  }

  /// Stream ya kuvuta messages kati ya watumishi wawili
  Stream<List<MessageModel>> getMessages({
    required String currentUserId,
    required String otherUserId,
  }) {
    final ids = [currentUserId, otherUserId]..sort();
    final conversationId = ids.join("_");

    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return MessageModel.fromMap(data, doc.id);
      }).toList();
    });
  }

  /// Kuongeza user mpya (ikiwa unataka kuinsert manual)
  Future<void> addUser(ChatModel user) async {
    await _firestore.collection(kUsersCollection).doc(user.id).set(user.toMap());
  }

  /// Kuupdate status ya user (mfano: online/offline)
  Future<void> updateUserStatus(String userId, bool isOnline) async {
    await _firestore.collection(kUsersCollection).doc(userId).update({
      'isOnline': isOnline,
      'lastSeen': isOnline ? null : Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Kutuma message kati ya watumishi wawili
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    final ids = [senderId, receiverId]..sort();
    final conversationId = ids.join("_");

    final convoRef = _firestore
        .collection('conversations')
        .doc(conversationId);

    final messageRef = convoRef
        .collection('messages')
        .doc();

    await _firestore.runTransaction((transaction) async {
      // Update conversation metadata
      transaction.set(convoRef, {
        'participants': ids,
        'lastMessage': content,
        'lastTimestamp': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));

      // Add message
      transaction.set(messageRef, {
        'id': messageRef.id,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'isRead': false,
        'messageType': 'text',
        'mediaUrl': null,
      });
    });
  }

  /// Kuupdate message kama imefikia (read)
  Future<void> markMessageAsRead({
    required String messageId,
    required String conversationId,
  }) async {
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .update({
      'isRead': true,
    });
  }

  /// Stream ya kuvuta conversations za user current
  Stream<List<Map<String, dynamic>>> getConversations(String currentUserId) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'conversationId': doc.id,
          'participants': data['participants'] as List<dynamic>,
          'lastMessage': data['lastMessage'] as String?,
          'lastTimestamp': data['lastTimestamp'] as Timestamp?,
        };
      }).toList();
    });
  }
}