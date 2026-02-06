import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
    print("Firebase initialization failed: $e");
  }

  runApp(MyApp(firebaseConnected: firebaseConnected));
}

class MyApp extends StatelessWidget {
  final bool firebaseConnected;
  const MyApp({super.key, required this.firebaseConnected});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Test App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(firebaseConnected: firebaseConnected),
    );
  }
}

class HomePage extends StatelessWidget {
  final bool firebaseConnected;
  const HomePage({super.key, required this.firebaseConnected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Connection Test"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Text(
          firebaseConnected
              ? "✅ Firebase Connection Successful!"
              : "❌ Firebase Connection Failed!",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
