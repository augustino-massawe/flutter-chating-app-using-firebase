import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/chat_service.dart';
import '../models/chat_model.dart';
import 'chat_room_screen.dart';
import '../widgets/chat_tile.dart';
import 'users_screen.dart';
import 'auth/login_screen.dart';


class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final String currentUserId = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            try {
              await _auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            } catch (e) {
              print('Sign out error: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sign out failed: $e')),
                );
              }
            }
          },
        ),
        title: const Text("Chats"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<ChatModel?>(
              stream: _getUserStream(currentUserId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person),
                  );
                }
                final user = snapshot.data!;
                return CircleAvatar(
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? const Icon(Icons.person)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search here...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          // List of conversations from Firestore (current user's conversations only)
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: ChatService().getConversations(currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No SMS"),
                  );
                }

                final conversations = snapshot.data!;

                return ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    final otherUserId = conversation['otherUserId'] as String? ?? '';
                    final lastMessage = conversation['lastMessage'] as String? ?? 'No message';
                    final lastTimestamp = conversation['lastTimestamp'] as Timestamp?;
                    
                    if (otherUserId.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    
                    return FutureBuilder<ChatModel?>(
                      future: _getUserData(otherUserId),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return _buildSkeletonConversationTile();
                        }
                        
                        if (!userSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final user = userSnapshot.data!;
                        
                        // Format timestamp
                        String timeText = '';
                        if (lastTimestamp != null) {
                          final now = DateTime.now();
                          final messageDate = lastTimestamp.toDate();
                          final difference = now.difference(messageDate);
                          
                          if (difference.inMinutes < 1) {
                            timeText = 'Sasa';
                          } else if (difference.inMinutes < 60) {
                            timeText = '${difference.inMinutes}m';
                          } else if (difference.inHours < 24) {
                            timeText = '${difference.inHours}h';
                          } else if (difference.inDays < 7) {
                            timeText = '${difference.inDays}d';
                          } else {
                            timeText = '${messageDate.day}/${messageDate.month}';
                          }
                        }
                        
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.photoURL != null
                                  ? NetworkImage(user.photoURL!)
                                  : null,
                              child: user.photoURL == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(
                              user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  timeText,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                if (user.isOnline)
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
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
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => UsersScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCurrentUserHeader(BuildContext context, String currentUserId) {
    return FutureBuilder<ChatModel?>(
      future: _getCurrentUserData(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSkeletonHeader();
        }
        
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final user = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[300],
                backgroundImage: user.photoURL != null 
                    ? NetworkImage(user.photoURL!) 
                    : null,
                child: user.photoURL == null 
                    ? Icon(Icons.person, size: 30, color: Colors.white) 
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: user.isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: user.isOnline ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // Add profile menu options here
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeletonHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 16,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 4),
              Container(
                width: 60,
                height: 12,
                color: Colors.grey[300],
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 24,
            height: 24,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonConversationTile() {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
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

  Future<ChatModel?> _getCurrentUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (!doc.exists) {
        return null;
      }
      
      return ChatModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('Error fetching current user data: $e');
      return null;
    }
  }

  Future<ChatModel?> _getUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (!doc.exists) {
        return null;
      }
      
      return ChatModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  /// Stream ya kuvuta user data realtime (kwa profile update)
  Stream<ChatModel?> _getUserStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return ChatModel.fromMap(doc.data()!, doc.id);
        });
  }
}
