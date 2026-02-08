import 'package:flutter/material.dart';

class ChatRoomScreen extends StatelessWidget {
  final String userName;
  const ChatRoomScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $userName'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Chat Room Page - hapa mtu mwingine ataendeleza kazi ya chat room',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
