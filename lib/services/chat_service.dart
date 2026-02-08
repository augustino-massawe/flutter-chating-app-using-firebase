import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream ya kuvuta users wote kutoka Firestore kwa realtime
  Stream<List<ChatModel>> getUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatModel.fromMap(data, doc.id);
      }).toList();
    });
  }

  /// Kuongeza user mpya (ikiwa unataka kuinsert manual)
  Future<void> addUser(ChatModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  /// Kuupdate status ya user (mfano: online/offline)
  Future<void> updateUserStatus(String userId, bool isOnline) async {
    await _firestore.collection('users').doc(userId).update({
      'isOnline': isOnline,
      'lastSeen': Timestamp.fromDate(DateTime.now()),
    });
  }
}
