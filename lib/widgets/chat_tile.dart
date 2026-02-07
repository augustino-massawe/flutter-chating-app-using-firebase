import 'package:flutter/material.dart';
import '../models/chat_model.dart';

class ChatTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback? onTap;

  const ChatTile({super.key, required this.chat, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: chat.photoURL != null && chat.photoURL!.isNotEmpty
            ? NetworkImage(chat.photoURL!)
            : const AssetImage('assets/default_avatar.png') as ImageProvider,
      ),
      title: Text(
        chat.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        chat.email,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatTimestamp(chat.createdAt),
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: onTap,
    );
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} h ago";
    } else {
      return "${diff.inDays} d ago";
    }
  }
}