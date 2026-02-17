import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/auth/splash_screen.dart';
import 'firebase_options.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseConnected = false;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseConnected = true;
  } catch (e) {
    firebaseConnected = false;
    // Optional: print error to console
    debugPrint("Firebase initialization failed: $e");
  }

  // Load persisted theme preference before running the app
  await ThemeService.init();

  runApp(MyApp(firebaseConnected: firebaseConnected));
}

class MyApp extends StatelessWidget {
  final bool firebaseConnected;
  const MyApp({super.key, required this.firebaseConnected});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Flutter Chat App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme:
                ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          themeMode: currentMode,
          home: SplashScreen(firebaseConnected: firebaseConnected),
        );
      },
    );
  }
}

class FirebaseErrorScreen extends StatelessWidget {
  const FirebaseErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Connection'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Text(
          'Firebase Connection Failed!',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
