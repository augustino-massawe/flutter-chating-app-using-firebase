import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
    String? pushToken,
  }) {
    final usersRef = _db.collection(kUsersCollection).doc(uid);
    return usersRef.set({
      'id': uid,
      'name': name.trim(),
      'email': email.trim(),
      'photoURL': photoUrl,
      'lastSeen': null,
      'isOnline': false,
      'createdAt': FieldValue.serverTimestamp(),
      'pushToken': pushToken,
    });
  }
}
