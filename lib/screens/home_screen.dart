import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/models/user_model.dart';

class HomeScreen extends StatefulWidget {
  final User firebaseUser;
  final UserModel userModel;

  const HomeScreen({
    super.key,
    required this.firebaseUser,
    required this.userModel,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Chat App'),
            const SizedBox(height: 20),
            Text('User: ${widget.userModel.name}'),
            const SizedBox(height: 10),
            Text('Email: ${widget.userModel.email}'),
          ],
        ),
      ),
    );
  }
}
