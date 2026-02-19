import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  late String _conversationId;
  late Stream<List<MessageModel>> _messagesStream;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser!.uid;

    // Build conversationId same way as chat_service.dart
    final ids = [_currentUserId, widget.receiverId]..sort();
    _conversationId = ids.join('_');

    _messagesStream = _chatService.getMessages(
      currentUserId: _currentUserId,
      otherUserId: widget.receiverId,
    );

    _scrollController = ScrollController();

    // Mark user as online
    _chatService.updateUserStatus(_currentUserId, true);

    // Mark ALL unread messages as read when chat room opens
    // This clears the unread badge on ChatsScreen immediately
    _markAllMessagesAsRead();
  }

  // Bulk mark-as-read — much more efficient than per-message marking
  Future<void> _markAllMessagesAsRead() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('conversations')
          .doc(_conversationId)
          .collection('messages')
          .where('receiverId', isEqualTo: _currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) return;

      // Use batch write for efficiency
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      debugPrint(
          'Marked ${snapshot.docs.length} messages as read');
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
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
                  ? const Icon(Icons.person,
                      size: 20, color: Colors.white)
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
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey),
                      );
                    }
                    final user = snapshot.data!.firstWhere(
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
                        color: user.isOnline
                            ? Colors.green
                            : Colors.grey,
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Call feature coming soon')),
              );
            },
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Video call feature coming soon')),
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
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
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

                // ✅ Mark any newly arrived unread messages as read
                // in real-time while the chat room is open
                _markAllMessagesAsRead();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe =
                        message.senderId == _currentUserId;

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