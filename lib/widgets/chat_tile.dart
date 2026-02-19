import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class ChatTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;
  final String currentUserId;

  const ChatTile({
    super.key,
    required this.chat,
    required this.onTap,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getConversationData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSkeletonTile();
        }

        if (!snapshot.hasData) {
          return _buildEmptyTile();
        }

        final data = snapshot.data!;
        final lastMessage = data['lastMessage'] as String?;
        final timestamp = data['timestamp'] as Timestamp?;
        final messageCount = data['messageCount'] as int?;

        return _buildChatTile(
          lastMessage: lastMessage,
          timestamp: timestamp,
          messageCount: messageCount,
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getConversationData() async {
    try {
      final ids = [currentUserId, chat.id]..sort();
      final conversationId = ids.join("_");

      // Get conversation document
      final convoDoc = await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (!convoDoc.exists) {
        return null;
      }

      // Get messages count
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .get();

      return {
        'lastMessage': convoDoc['lastMessage'] as String?,
        'timestamp': convoDoc['lastTimestamp'] as Timestamp?,
        'messageCount': messagesSnapshot.size,
      };
    } catch (e) {
      print('Error fetching conversation data: $e');
      return null;
    }
  }

  Widget _buildSkeletonTile() {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[300],
        child: Icon(Icons.person, size: 30, color: Colors.white),
      ),
      title: Container(
        height: 16,
        width: 100,
        color: Colors.grey[300],
      ),
      subtitle: Container(
        height: 12,
        width: 150,
        color: Colors.grey[300],
      ),
      trailing: Container(
        height: 16,
        width: 60,
        color: Colors.grey[300],
      ),
    );
  }

  Widget _buildEmptyTile() {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[300],
        backgroundImage: chat.photoURL != null 
            ? NetworkImage(chat.photoURL!) 
            : null,
        child: chat.photoURL == null 
            ? Icon(Icons.person, size: 30, color: Colors.white) 
            : null,
      ),
      title: Text(
        chat.name,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: chat.isOnline ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                chat.isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 12,
                  color: chat.isOnline ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: const Text(
        '0',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildChatTile({
    String? lastMessage,
    Timestamp? timestamp,
    int? messageCount,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[300],
        backgroundImage: chat.photoURL != null 
            ? NetworkImage(chat.photoURL!) 
            : null,
        child: chat.photoURL == null 
            ? Icon(Icons.person, size: 30, color: Colors.white) 
            : null,
      ),
      title: Text(
        chat.name,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lastMessage ?? 'No messages yet',
            style: TextStyle(
              fontSize: 14,
              color: lastMessage == null ? Colors.grey[600] : Colors.black87,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: chat.isOnline ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                chat.isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 12,
                  color: chat.isOnline ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (timestamp != null)
            Text(
              _formatTimestamp(timestamp),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              messageCount?.toString() ?? '0',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
