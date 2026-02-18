import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../services/language_service.dart';
import '../screens/auth/login_screen.dart';
import '../utils/app_localizations.dart';
import 'help_support_screen.dart';
import 'privacy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  Future<void> _handleLogout() async {
    try {
      await AuthService().signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "User Profile",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Manage your account settings",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Language Selection
          Card(
            elevation: 2,
            child: ValueListenableBuilder<Locale>(
              valueListenable: LanguageService.localeNotifier,
              builder: (context, locale, _) {
                return Column(
                  children: [
                    RadioListTile<String>(
                      title: Text(loc.english),
                      secondary: const Icon(Icons.language),
                      value: 'en',
                      groupValue: locale.languageCode,
                      onChanged: (v) {
                        if (v != null) LanguageService.setLanguage(v);
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: Text(loc.swahili),
                      secondary: const Icon(Icons.language),
                      value: 'sw',
                      groupValue: locale.languageCode,
                      onChanged: (v) {
                        if (v != null) LanguageService.setLanguage(v);
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Theme selection (System / Light / Dark)
          Card(
            elevation: 2,
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeService.themeNotifier,
              builder: (context, mode, _) {
                return Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: const Text('System Default'),
                      secondary: const Icon(Icons.phone_android),
                      value: ThemeMode.system,
                      groupValue: mode,
                      onChanged: (v) {
                        if (v != null) ThemeService.setTheme(v);
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: const Text('Light (Default)'),
                      secondary: const Icon(Icons.wb_sunny),
                      value: ThemeMode.light,
                      groupValue: mode,
                      onChanged: (v) {
                        if (v != null) ThemeService.setTheme(v);
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: const Text('Dark'),
                      secondary: const Icon(Icons.nights_stay),
                      value: ThemeMode.dark,
                      groupValue: mode,
                      onChanged: (v) {
                        if (v != null) ThemeService.setTheme(v);
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Settings Options
          Card(
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: const Text("Profile"),
                  subtitle: const Text("View and edit your profile"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.green),
                  title: const Text("Notifications"),
                  subtitle: const Text("Manage notification settings"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security, color: Colors.orange),
                  title: const Text("Privacy"),
                  subtitle: const Text("Manage your privacy settings"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrivacyScreen()),
                    );
                  },
                ),
                const Divider(height: 1),

                // 👇 HELP & SUPPORT NAVIGATION ADDED
                ListTile(
                  leading: const Icon(Icons.help, color: Colors.purple),
                  title: const Text("Help & Support"),
                  subtitle: const Text("Get help and support"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpSupportScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Logout Button
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                loc.logout,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _handleLogout,
            ),
          ),
        ],
      ),
    );
  }
}