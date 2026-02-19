import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';
import 'chats_screen.dart';
import 'users_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Telegram-like colors
  static const Color primaryBlue = Color(0xFF2AABEE);
  static const Color inactiveGrey = Color(0xFF9E9E9E);

  final List<Widget> _pages = [
    const ChatsScreen(),
    UsersScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // ── Persistent Auth Guard ───────────────────────────────────────────────
    // If somehow HomeScreen is reached without a valid session,
    // redirect immediately to Login. This is a safety net on top of AuthGate.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
    });

    // Start listening for new messages from all chat rooms
    // Shows notification banner when a new message arrives
    NotificationService().startListeningForMessages();
  }

  @override
  void dispose() {
    // Stop all Firestore listeners when HomeScreen is disposed
    NotificationService().stopListeningForMessages();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ── Real-time Auth Stream Listener ──────────────────────────────────────
    // Listens continuously while HomeScreen is active.
    // If the user's session expires or they are signed out from another device,
    // this will automatically redirect them to Login instantly.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Session lost while on HomeScreen — redirect to Login immediately
        if (snapshot.connectionState != ConnectionState.waiting &&
            (!snapshot.hasData || snapshot.data == null)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
        }

        // ── Normal HomeScreen UI ────────────────────────────────────────────
        return Scaffold(
          body: _pages[_selectedIndex],

          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,

            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            elevation: 12,

            selectedItemColor: primaryBlue,
            unselectedItemColor: inactiveGrey,

            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 11,
            ),

            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Chats',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Users',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
