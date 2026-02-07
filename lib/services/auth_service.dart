import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    if (kDebugMode) {
      print('Registering user with email: ${email.trim()}');
      print('Password length: ${password.trim().length}');
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      if (kDebugMode) {
        print('Registration successful for user: ${credential.user?.email}');
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Exception:');
        print('Code: ${e.code}');
        print('Message: ${e.message}');
        print('Email: ${email.trim()}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('General Exception during registration: $e');
      }
      rethrow;
    }
  }
}
