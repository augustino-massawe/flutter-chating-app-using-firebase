import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final Timestamp? lastSeen;
  final bool isOnline;
  final Timestamp? createdAt;
  final String? pushToken;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.lastSeen,
    required this.isOnline,
    this.createdAt,
    this.pushToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoURL': photoUrl,
      'lastSeen': lastSeen,
      'isOnline': isOnline,
      'createdAt': createdAt,
      'pushToken': pushToken,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      photoUrl: map['photoURL'] as String?,
      lastSeen: map['lastSeen'] as Timestamp?,
      isOnline: map['isOnline'] as bool? ?? false,
      createdAt: map['createdAt'] as Timestamp?,
      pushToken: map['pushToken'] as String?,
    );
  }
}
