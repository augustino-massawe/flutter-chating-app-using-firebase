# Language Switching Feature Implementation

## Overview
This document explains the multi-language support (English & Swahili) implementation in the Flutter Chat App.

---

## Files Created/Modified

### 1. **New Files Created:**

#### `lib/services/language_service.dart`
- Manages language switching across the app
- Uses `ValueNotifier` to notify all listeners when language changes
- Persists language preference to `SharedPreferences`
- Key methods:
  - `init()` - Initialize language on app startup
  - `setLanguage(String languageCode)` - Change language and save preference
  - `getCurrentLanguage()` - Get current language code
  - `isSwahili()` / `isEnglish()` - Helper methods

#### `lib/utils/app_strings.dart`
- Contains all UI strings for both English and Swahili
- Stores translations in a nested map structure
- Supports 50+ common UI strings including:
  - Authentication screens (Login, Register, etc.)
  - Chat screens (Messages, Users, etc.)
  - Settings & Navigation
  - Error messages and validation

#### `lib/utils/app_localizations.dart`
- Provides `AppLocalizations` class for accessing translations
- Implements `LocalizationsDelegate` for Flutter's localization framework
- Provides quick-access getter methods for common strings
- Supports both English ('en') and Swahili ('sw') locales

### 2. **Modified Files:**

#### `pubspec.yaml`
- Added `flutter_localizations: sdk: flutter`
- Added `generate: true` flag in flutter section

#### `lib/main.dart`
- Imported new localization classes
- Added `LanguageService.init()` call in `main()`
- Updated `MyApp` widget to listen to `LanguageService.localeNotifier`
- Added `localizationsDelegates` and `supportedLocales` to MaterialApp
- Wrapped MaterialApp with `ValueListenableBuilder` for language reactivity

#### `lib/screens/settings_screen.dart`
- Added language selection UI with radio buttons
- Imported `LanguageService` and `AppLocalizations`
- Added English/Swahili toggle in settings
- Updated UI strings to use localized values

#### `lib/screens/home_screen.dart`
- Updated bottom navigation labels to use localized strings
- Imported `AppLocalizations`

---

## How to Use

### **For End Users (In Settings Screen):**

1. Navigate to **Settings** tab
2. Look for **Language** section (appears after Profile section)
3. Toggle between:
   - **English** 📌 English (Kiingereza)
   - **Swahili** 📌 Kiswahili
4. Changes apply immediately across the entire app
5. Preference is automatically saved

### **For Developers (Adding New Translations):**

#### 1. Add new string keys to `lib/utils/app_strings.dart`

```dart
static const Map<String, Map<String, String>> _translations = {
  'en': {
    'newKey': 'English translation',
    ...
  },
  'sw': {
    'newKey': 'Swahili translation',
    ...
  },
};
```

#### 2. Add getter method in `lib/utils/app_localizations.dart`

```dart
String get newKey => translate('newKey');
```

#### 3. Use in widgets:

```dart
final loc = AppLocalizations.of(context);
Text(loc.newKey);

// Or directly:
Text(AppLocalizations.of(context).translate('newKey'));
```

---

## Architecture

### **Language Flow:**

```
app starts
    ↓
LanguageService.init() → loads saved preference from SharedPreferences
    ↓
main.dart → LanguageService.localeNotifier (ValueNotifier)
    ↓
MaterialApp listens to localeNotifier changes
    ↓
AppLocalizationsDelegate rebuilds AppLocalizations with new locale
    ↓
All widgets get new translations automatically
```

### **Data Flow for Language Change:**

1. User selects language in Settings
2. `LanguageService.setLanguage(languageCode)` called
3. Preference saved to SharedPreferences
4. `localeNotifier.value` updated
5. All `ValueListenableBuilder` widgets rebuild
6. `AppLocalizationsDelegate.load()` rebuilds with new locale
7. Entire app UI updates with new language

---

## Current Translations

### **English Strings Included (50+):**
- Authentication: login, register, email, password, signUp, signIn, etc.
- Navigation: chats, users, settings, home, search
- Chat: typeMessage, send, messageRead, messageDelivered
- Settings: language, theme, darkMode, lightMode, logout
- And more...

### **Swahili Translations (50+):**
- Ingia (Login)
- Jisajili (Register)
- Barua Pepe (Email)
- Nenosiri (Password)
- Mazungumzo (Chats)
- Watumiaji (Users)
- Mipangilio (Settings)
- And more...

---

## Adding More Translations

To add Swahili translations for existing English strings:

1. Find the English string in `app_strings.dart`
2. Add corresponding Swahili translation in the 'sw' map
3. Use in your widget as shown above

**Example:**
```dart
'en': {
  'myFeature': 'My Feature',
},
'sw': {
  'myFeature': 'Kipengele Changu',
}
```

---

## Testing Language Switch

1. Run the app: `flutter run`
2. Navigate to Settings tab
3. Select Swahili → entire UI changes to Swahili
4. Select English → entire UI changes back to English
5. Close and reopen app → language preference persists

---

## Technical Details

- **Locale Management**: Uses Flutter's built-in `Locale` class
- **State Management**: `ValueNotifier` (reactive)
- **Persistence**: `SharedPreferences` (key: 'app_language')
- **Supported Locales**: 'en' (English), 'sw' (Swahili)
- **Localization Delegate**: Custom `AppLocalizationsDelegate`

---

## Best Practices

✅ Always use `AppLocalizations.of(context).stringName` for UI text
✅ Add new translations to both 'en' and 'sw' maps simultaneously
✅ Use descriptive key names in snake_case
✅ Test UI with different text lengths (Swahili can be longer)
✅ Keep language selection persistent using SharedPreferences

---

## Future Enhancements

- [ ] Add more languages (French, German, etc.)
- [ ] Use `.arb` files for professional localization
- [ ] Implement RTL support for Arabic
- [ ] Use Firebase Remote Config for dynamic translations
- [ ] Add language selection on first app launch

---

## Troubleshooting

**Issue**: App shows English even after selecting Swahili
- **Solution**: Clear app cache/data and restart the app

**Issue**: New translations not appearing
- **Solution**: Restart the development server and rebuild (`flutter clean && flutter run`)

**Issue**: Language doesn't persist after closing app
- **Solution**: Ensure `LanguageService.init()` is called in `main()` before `runApp()`

---

## Files Reference

```
lib/
├── services/
│   └── language_service.dart          [NEW] Language state management
├── utils/
│   ├── app_strings.dart               [NEW] Translation strings
│   └── app_localizations.dart         [NEW] Localization delegate
├── screens/
│   ├── settings_screen.dart           [MODIFIED] Added language UI
│   └── home_screen.dart               [MODIFIED] Localized bottom nav
└── main.dart                          [MODIFIED] Added localization support
```

---

**Created**: February 18, 2026
**Version**: 1.0
