import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.question_answer, color: Colors.blue),
            title: Text("FAQs"),
            subtitle: Text("Frequently Asked Questions"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.email, color: Colors.green),
            title: Text("Contact Us"),
            subtitle: Text("support@example.com"),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info, color: Colors.orange),
            title: Text("About App"),
            subtitle: Text("Version 1.0.0"),
          ),
        ],
      ),
    );
  }
}