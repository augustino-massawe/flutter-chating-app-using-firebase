import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/services/chat_service.dart';
import 'package:flutter_chat_app/models/chat_model.dart';
import 'chat_room_screen.dart';

class UsersScreen extends StatelessWidget {
  UsersScreen({super.key});

  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final String currentUserId = _auth.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Watumiaji"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: _chatService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Hitilafu: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Hakuna watumiaji'),
            );
          }

          // Filter out current user
          final users = snapshot.data!
              .where((user) => user.id != currentUserId)
              .toList();

          if (users.isEmpty) {
            return const Center(
              child: Text('Hakuna watumiaji wengine'),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(user.name),
                  subtitle: Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: user.isOnline
                      ? Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoomScreen(
                          userName: user.name,
                          receiverId: user.id,
                          receiverPhotoUrl: user.photoURL,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
