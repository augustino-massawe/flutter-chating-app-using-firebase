// Example: How to Use Language/Localization in Your Screens

import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import '../services/language_service.dart';

// ============================================
// EXAMPLE 1: Simple Widget Using Localization
// ============================================
class ExampleScreen1 extends StatelessWidget {
  const ExampleScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the localization instance
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings), // "Settings" or "Mipangilio"
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(loc.welcome), // Uses current language
            const SizedBox(height: 16),
            Text(loc.chats),
            Text(loc.users),
          ],
        ),
      ),
    );
  }
}

// ============================================
// EXAMPLE 2: Check Current Language
// ============================================
class ExampleScreen2 extends StatelessWidget {
  const ExampleScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isSwahili = LanguageService.isSwahili();
    final isEnglish = LanguageService.isEnglish();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSwahili)
              Text(loc.swahili)
            else if (isEnglish)
              Text(loc.english),
            const SizedBox(height: 16),
            Text('Current: ${LanguageService.getCurrentLanguage()}'),
          ],
        ),
      ),
    );
  }
}

// ============================================
// EXAMPLE 3: Language-Sensitive Widget
// ============================================
class ExampleScreen3 extends StatefulWidget {
  const ExampleScreen3({super.key});

  @override
  State<ExampleScreen3> createState() => _ExampleScreen3State();
}

class _ExampleScreen3State extends State<ExampleScreen3> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.home),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.chat),
            title: Text(loc.chats),
            subtitle: Text(loc.typeMessage),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: Text(loc.users),
            subtitle: Text(loc.onlineUsers),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(loc.language),
            subtitle: Text('Current: ${LanguageService.getCurrentLanguage()}'),
          ),
        ],
      ),
    );
  }
}

// ============================================
// EXAMPLE 4: Listen to Language Changes
// ============================================
class ExampleScreen4 extends StatefulWidget {
  const ExampleScreen4({super.key});

  @override
  State<ExampleScreen4> createState() => _ExampleScreen4State();
}

class _ExampleScreen4State extends State<ExampleScreen4> {
  @override
  void initState() {
    super.initState();
    // Listen to language changes
    LanguageService.localeNotifier.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    // Rebuild when language changes
    setState(() {});
  }

  @override
  void dispose() {
    LanguageService.localeNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Language: ${LanguageService.getCurrentLanguage()}'),
            const SizedBox(height: 16),
            Text(loc.welcome),
          ],
        ),
      ),
    );
  }
}

// ============================================
// EXAMPLE 5: Using ValueListenableBuilder
// ============================================
class ExampleScreen5 extends StatelessWidget {
  const ExampleScreen5({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.localeNotifier,
      builder: (context, locale, _) {
        final loc = AppLocalizations.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(loc.settings),
          ),
          body: Center(
            child: Text('Current Language: ${locale.languageCode}'),
          ),
        );
      },
    );
  }
}

// ============================================
// EXAMPLE 6: Programmatically Change Language
// ============================================
class ExampleScreen6 extends StatelessWidget {
  const ExampleScreen6({super.key});

  void _changeLanguage(String languageCode) {
    LanguageService.setLanguage(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _changeLanguage('en'),
              child: Text(loc.english),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _changeLanguage('sw'),
              child: Text(loc.swahili),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// EXAMPLE 7: Custom String with Fallback
// ============================================
class ExampleScreen7 extends StatelessWidget {
  const ExampleScreen7({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using translate method directly
            Text(
              AppLocalizations.of(context).translate('login'),
            ),
            const SizedBox(height: 16),
            // Using shortcut getter
            Text(loc.login),
            const SizedBox(height: 16),
            // With fallback
            Text(
              AppLocalizations.of(context).translate('nonexistentKey'),
              // Falls back to 'nonexistentKey' if translation not found
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// BEST PRACTICES
// ============================================
/*
✅ DO:
- Use AppLocalizations.of(context).stringKey in build methods
- Add translations to both 'en' and 'sw' in app_strings.dart
- Use ValueListenableBuilder for language-dependent UI
- Test UI with different text lengths
- Save language preference (already handled by LanguageService)

❌ DON'T:
- Use hardcoded strings in UI
- Forget to add both English and Swahili translations
- Use context outside build method for localization
- Store language preference manually (LanguageService handles it)
*/

// ============================================
// ADDING NEW TRANSLATIONS
// ============================================
/*
1. Open lib/utils/app_strings.dart
2. Add key to both 'en' and 'sw' maps:

   'en': {
     'myNewString': 'My English Text',
   },
   'sw': {
     'myNewString': 'Maandishi Yangu ya Kiswahili',
   }

3. Open lib/utils/app_localizations.dart
4. Add getter method:

   String get myNewString => translate('myNewString');

5. Use in your widget:

   final loc = AppLocalizations.of(context);
   Text(loc.myNewString);
*/
