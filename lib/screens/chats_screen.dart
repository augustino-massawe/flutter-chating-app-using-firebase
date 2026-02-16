import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/chat_service.dart';
import '../models/chat_model.dart';
import 'chat_room_screen.dart';
import '../widgets/chat_tile.dart';
import 'users_screen.dart';
import 'auth/login_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  // Modern color scheme
  static const Color primaryBlue = Color(0xFF0088CC);
  static const Color accentBlue = Color(0xFF2AABEE);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF707579);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final String currentUserId = _auth.currentUser!.uid;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cardColor,
        leading: IconButton(
          icon: Icon(Icons.menu, color: textPrimary),
          onPressed: () => _showMenuBottomSheet(context, _auth),
        ),
        title: const Text(
          "Chats",
          style: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => _navigateToProfile(context, currentUserId),
              child: StreamBuilder<ChatModel?>(
                stream: _getUserStream(currentUserId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person, color: Colors.grey[600], size: 20),
                    );
                  }
                  final user = snapshot.data!;
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryBlue.withOpacity(0.3), width: 2),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? Icon(Icons.person, color: Colors.grey[600], size: 20)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // Search bar with modern design
          Container(
            color: cardColor,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search conversations...",
                  hintStyle: TextStyle(color: textSecondary.withOpacity(0.6), fontSize: 15),
                  prefixIcon: Icon(Icons.search, color: textSecondary, size: 22),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: textSecondary, size: 20),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          // Conversations list
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: ChatService().getConversations(currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: textSecondary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No conversations yet",
                          style: TextStyle(
                            fontSize: 18,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Start chatting with your friends",
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final conversations = snapshot.data!;

                return FutureBuilder<List<_ConversationData>>(
                  future: _prepareConversations(conversations, currentUserId),
                  builder: (context, conversationsSnapshot) {
                    if (conversationsSnapshot.connectionState == ConnectionState.waiting) {
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: 5,
                        itemBuilder: (context, index) => _buildSkeletonConversationTile(),
                      );
                    }

                    if (!conversationsSnapshot.hasData || conversationsSnapshot.data!.isEmpty) {
                      return const Center(child: Text("No conversations found"));
                    }

                    var filteredConversations = conversationsSnapshot.data!;

                    // Apply search filter
                    if (_searchQuery.isNotEmpty) {
                      filteredConversations = filteredConversations.where((conv) {
                        return conv.user.name.toLowerCase().contains(_searchQuery) ||
                            conv.lastMessage.toLowerCase().contains(_searchQuery);
                      }).toList();
                    }

                    if (filteredConversations.isEmpty && _searchQuery.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: textSecondary.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No results found',
                              style: TextStyle(
                                fontSize: 16,
                                color: textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try searching with different keywords',
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: filteredConversations.length,
                      itemBuilder: (context, index) {
                        final convData = filteredConversations[index];
                        return _buildConversationTile(
                          convData.user,
                          convData.lastMessage,
                          convData.lastTimestamp,
                          convData.unreadCount,
                          currentUserId,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Modern floating action button
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => UsersScreen()),
            );
          },
          backgroundColor: primaryBlue,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.edit_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  // --------- CONVERSATION TILE BUILDER ---------

  Widget _buildConversationTile(
      ChatModel user,
      String lastMessage,
      Timestamp? lastTimestamp,
      int unreadCount,
      String currentUserId,
      ) {
    String timeText = '';

    if (lastTimestamp != null) {
      final now = DateTime.now();
      final messageDate = lastTimestamp.toDate();
      final diff = now.difference(messageDate);

      if (diff.inMinutes < 1) {
        timeText = 'Now';
      } else if (diff.inMinutes < 60) {
        timeText = '${diff.inMinutes}m';
      } else if (diff.inHours < 24) {
        timeText = '${diff.inHours}h';
      } else if (diff.inDays < 7) {
        timeText = '${diff.inDays}d';
      } else {
        timeText = '${messageDate.day}/${messageDate.month}';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border(
          bottom: BorderSide(
            color: backgroundColor,
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatRoomScreen(
                  userName: user.name,
                  receiverId: user.id,
                  receiverPhotoUrl: user.photoURL,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Avatar with online indicator
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : null,
                        child: user.photoURL == null
                            ? Icon(Icons.person, color: Colors.grey[600], size: 28)
                            : null,
                      ),
                    ),
                    if (user.isOnline)
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cardColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Name and message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: unreadCount > 0 ? FontWeight.w700 : FontWeight.w600,
                          color: textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: unreadCount > 0 ? textPrimary : textSecondary,
                          fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Time and unread badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timeText,
                      style: TextStyle(
                        fontSize: 12,
                        color: unreadCount > 0 ? primaryBlue : textSecondary.withOpacity(0.8),
                        fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    if (unreadCount > 0) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        constraints: const BoxConstraints(minWidth: 20),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------- HELPERS ---------

  Future<List<_ConversationData>> _prepareConversations(
      List<Map<String, dynamic>> conversations,
      String currentUserId,
      ) async {
    List<_ConversationData> result = [];

    for (var conversation in conversations) {
      final otherUserId = conversation['otherUserId'] as String? ?? '';
      if (otherUserId.isEmpty) continue;

      final user = await _getUserData(otherUserId);
      if (user == null) continue;

      final lastMessage = conversation['lastMessage'] as String? ?? 'No message';
      final lastTimestamp = conversation['lastTimestamp'] as Timestamp?;
      final unreadCount = await ChatService().getUnreadCount(currentUserId, otherUserId);

      result.add(_ConversationData(
        user: user,
        lastMessage: lastMessage,
        lastTimestamp: lastTimestamp,
        unreadCount: unreadCount,
      ));
    }

    return result;
  }

  String _getChatId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  void _navigateToProfile(BuildContext context, String userId) {
    // Navigate to profile screen
    // Replace with your actual profile screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile'),
        content: const Text('Profile screen will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    // Uncomment and modify when you have a profile screen:
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (_) => ProfileScreen(userId: userId),
    //   ),
    // );
  }

  void _showMenuBottomSheet(BuildContext context, FirebaseAuth auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                _navigateToProfile(context, auth.currentUser!.uid);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to help
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                try {
                  await auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sign out failed: $e')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonConversationTile() {
    return Container(
      color: cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 1),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 12,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Future<ChatModel?> _getUserData(String userId) async {
    final doc =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return ChatModel.fromMap(doc.data()!, doc.id);
  }

  Stream<ChatModel?> _getUserStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) =>
    doc.exists ? ChatModel.fromMap(doc.data()!, doc.id) : null);
  }
}

// --------- DATA CLASS ---------
class _ConversationData {
  final ChatModel user;
  final String lastMessage;
  final Timestamp? lastTimestamp;
  final int unreadCount;

  _ConversationData({
    required this.user,
    required this.lastMessage,
    required this.lastTimestamp,
    required this.unreadCount,
  });
}