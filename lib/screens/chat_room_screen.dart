import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/models/message_model.dart';
import 'package:flutter_chat_app/services/chat_service.dart';
import 'package:flutter_chat_app/widgets/chat_input.dart';
import 'package:flutter_chat_app/widgets/message_bubble.dart';
import 'package:flutter_chat_app/models/chat_model.dart';
import 'package:flutter_chat_app/services/firestore_service.dart';

class ChatRoomScreen extends StatefulWidget {
  final String userName;
  final String receiverId;
  final String? receiverPhotoUrl;

  const ChatRoomScreen({
    super.key,
    required this.userName,
    required this.receiverId,
    this.receiverPhotoUrl,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ChatService _chatService = ChatService();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _currentUserId;
  late Stream<List<MessageModel>> _messagesStream;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser!.uid;
    _messagesStream = _chatService.getMessages(
      currentUserId: _currentUserId,
      otherUserId: widget.receiverId,
    );
    _scrollController = ScrollController();
    
    // Mark user as online
    _chatService.updateUserStatus(_currentUserId, true);
    
    // Mark all messages as read when opening chat
    _markAllMessagesAsRead();
  }

  void _markAllMessagesAsRead() async {
    await _chatService.markAllMessagesAsRead(_currentUserId, widget.receiverId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Mark user as offline when leaving chat
    _chatService.updateUserStatus(_currentUserId, false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              backgroundImage: widget.receiverPhotoUrl != null 
                  ? NetworkImage(widget.receiverPhotoUrl!) 
                  : null,
              child: widget.receiverPhotoUrl == null 
                  ? Icon(Icons.person, size: 20, color: Colors.white) 
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(fontSize: 16),
                ),
                StreamBuilder<List<ChatModel>>(
                  stream: _chatService.getUsers(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text(
                        'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      );
                    }
                    
                    final user = snapshot.data!
                        .firstWhere(
                          (u) => u.id == widget.receiverId,
                          orElse: () => ChatModel(
                            id: '',
                            name: '',
                            email: '',
                            createdAt: DateTime.now(),
                            isOnline: false,
                          ),
                        );
                    
                    return Text(
                      user.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: user.isOnline ? Colors.green : Colors.grey,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Handle call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Call feature coming soon'),
                ),
              );
            },
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {
              // Handle video call
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Video call feature coming soon'),
                ),
              );
            },
            icon: const Icon(Icons.video_call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet. Start the conversation!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _currentUserId;
                    
                    // Mark message as read if it's received and not read
                    if (!isMe && !message.isRead) {
                      final ids = [_currentUserId, widget.receiverId]..sort();
                      final conversationId = ids.join("_");
                      _chatService.markMessageAsRead(
                        messageId: message.id,
                        conversationId: conversationId,
                      );
                    }

                    return MessageBubble(
                      message: message,
                      isMe: isMe,
                      receiverName: widget.userName,
                    );
                  },
                );
              },
            ),
          ),
          ChatInput(
            currentUserId: _currentUserId,
            receiverId: widget.receiverId,
            receiverName: widget.userName,
          ),
        ],
      ),
    );
  }
}
