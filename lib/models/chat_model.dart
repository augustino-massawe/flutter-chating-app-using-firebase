import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String name;
  final String email;
  final String? photoURL;
  final DateTime createdAt;
  final bool isOnline;
  final DateTime? lastSeen;
  final String? pushToken;

  ChatModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoURL,
    required this.createdAt,
    required this.isOnline,
    this.lastSeen,
    this.pushToken,
  });

  // Convert Firestore document to ChatModel
  factory ChatModel.fromMap(Map<String, dynamic> data, String id) {
    return ChatModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isOnline: data['isOnline'] ?? false,
      lastSeen: data['lastSeen'] != null
          ? (data['lastSeen'] as Timestamp).toDate()
          : null,
      pushToken: data['pushToken'],
    );
  }

  // Convert ChatModel to Map (useful for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'pushToken': pushToken,
    };
  }
}
