# 🌍 Language Switching Setup Guide

## Quick Start

### ✅ What's Been Added:

1. **Multi-language Support** - Switch between English & Swahili
2. **Language Settings UI** - Toggle in Settings screen
3. **Persistent Storage** - Language preference saved
4. **Reactive Updates** - Entire app updates instantly when language changes

---

## How to Test

### Step 1: Get Dependencies
```bash
flutter pub get
```

### Step 2: Run the App
```bash
flutter run
```

### Step 3: Test Language Switching

1. **Navigate to Settings Tab** (bottom right icon)
2. **Scroll down** to see the **Language** section
3. **Select Swahili** → App instantly changes to Swahili
4. **Select English** → App changes back to English
5. **Close and reopen app** → Language setting persists

---

## What Changed?

### 📁 New Files:
- `lib/services/language_service.dart` - Language manager
- `lib/utils/app_strings.dart` - All translations (English & Swahili)
- `lib/utils/app_localizations.dart` - Localization delegate
- `LANGUAGE_FEATURE.md` - Detailed documentation

### 📝 Modified Files:
- `pubspec.yaml` - Added flutter_localizations
- `main.dart` - Integrated language system
- `lib/screens/settings_screen.dart` - Added language toggle UI
- `lib/screens/home_screen.dart` - Localized navigation labels

---

## Current Translations (Examples)

| Key | English | Swahili |
|-----|---------|---------|
| chats | Chats | Mazungumzo |
| users | Users | Watumiaji |
| settings | Settings | Mipangilio |
| login | Login | Ingia |
| register | Register | Jisajili |
| typeMessage | Type a message... | Andika ujumbe... |
| send | Send | Tuma |
| logout | Logout | Toka |

---

## Adding New Translations

### To add a new translated string:

1. **Open** `lib/utils/app_strings.dart`
2. **Add** your string to both 'en' and 'sw' maps:
```dart
'en': {
  'myString': 'My English Text',
},
'sw': {
  'myString': 'Maandishi Yangu ya Kiswahili',
}
```

3. **Open** `lib/utils/app_localizations.dart`
4. **Add** a getter method:
```dart
String get myString => translate('myString');
```

5. **Use** in your widget:
```dart
final loc = AppLocalizations.of(context);
Text(loc.myString);
```

---

## Architecture Overview

```
User selects language in Settings
         ↓
LanguageService.setLanguage(code)
         ↓
Save to SharedPreferences
         ↓
Update localeNotifier (ValueNotifier)
         ↓
MaterialApp listens & updates locale
         ↓
Entire app rebuilds with new language
```

---

## File Structure

```
lib/
├── services/
│   ├── auth_service.dart
│   ├── chat_service.dart
│   ├── firestore_service.dart
│   ├── language_service.dart        ← NEW
│   ├── privacy_service.dart
│   └── theme_service.dart
├── utils/
│   ├── constants.dart
│   ├── validators.dart
│   ├── app_strings.dart             ← NEW
│   └── app_localizations.dart       ← NEW
├── screens/
│   ├── settings_screen.dart         ← MODIFIED
│   └── home_screen.dart             ← MODIFIED
└── main.dart                        ← MODIFIED
```

---

## FAQ

**Q: Will language persist after closing the app?**
A: Yes! The preference is saved to SharedPreferences automatically.

**Q: Can I add more languages?**
A: Yes! Add new language codes to `app_strings.dart` and `AppLocalizationsDelegate.isSupported()`.

**Q: How do I use translations in new screens?**
A: Import `AppLocalizations` and call: `AppLocalizations.of(context).yourStringKey`

**Q: What if translations are missing?**
A: The app falls back to English. Check `app_strings.dart` to add missing translations.

---

## Commands to Run

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Build for release
flutter build apk    # For Android
flutter build ios    # For iOS
```

---

**Ready to go!** 🚀 The language switching feature is fully integrated and ready to use.

For detailed documentation, see `LANGUAGE_FEATURE.md`
