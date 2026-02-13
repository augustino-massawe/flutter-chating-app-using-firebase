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
    try {
      final ids = [senderId, receiverId]..sort();
      final conversationId = ids.join("_");
      final timestamp = Timestamp.fromDate(DateTime.now());

      // Save conversation metadata
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .set({
        'conversationId': conversationId,
        'participants': ids,
        'lastMessage': content,
        'lastTimestamp': timestamp,
        'updatedAt': timestamp,
      }, SetOptions(merge: true));

      // Save message in sub-collection
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'timestamp': timestamp,
        'isRead': false,
        'messageType': 'text',
        'mediaUrl': null,
      });
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
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
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) {
            final participants = doc['participants'] as List<dynamic>? ?? [];
            return participants.contains(currentUserId);
          })
          .toList()
          .map((doc) {
            final data = doc.data();
            final participants = data['participants'] as List<dynamic>? ?? [];
            final otherUserId = participants.firstWhere(
              (id) => id != currentUserId,
              orElse: () => '',
            );

            return {
              'conversationId': doc.id,
              'participants': participants,
              'lastMessage': data['lastMessage'] as String? ?? '',
              'lastTimestamp': data['lastTimestamp'] as Timestamp?,
              'otherUserId': otherUserId,
            };
          })
          .toList()
          ..sort((a, b) {
            final timestampA = (a['lastTimestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);
            final timestampB = (b['lastTimestamp'] as Timestamp?)?.toDate() ?? DateTime(1970);
            return timestampB.compareTo(timestampA);
          });
    });
  }

  /// Kuvuta conversation data kwa user fulani
  Future<Map<String, dynamic>?> getConversationData(String currentUserId, String otherUserId) async {
    try {
      final ids = [currentUserId, otherUserId]..sort();
      final conversationId = ids.join("_");

      final convoDoc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!convoDoc.exists) {
        return null;
      }

      final messagesSnapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .get();

      return {
        'conversationId': conversationId,
        'lastMessage': convoDoc['lastMessage'] as String?,
        'timestamp': convoDoc['lastTimestamp'] as Timestamp?,
        'messageCount': messagesSnapshot.size,
      };
    } catch (e) {
      print('Error fetching conversation data: $e');
      return null;
    }
  }
}