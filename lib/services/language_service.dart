import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'app_language';
  static final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en'));

  /// Initialize language service and load saved preference
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    localeNotifier.value = Locale(languageCode);
  }

  /// Change language and save preference
  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    localeNotifier.value = Locale(languageCode);
  }

  /// Get current language code
  static String getCurrentLanguage() {
    return localeNotifier.value.languageCode;
  }

  /// Check if current language is Swahili
  static bool isSwahili() {
    return getCurrentLanguage() == 'sw';
  }

  /// Check if current language is English
  static bool isEnglish() {
    return getCurrentLanguage() == 'en';
  }
}
