import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const _prefsKey = 'theme_mode';

  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.system);

  // Initialize from persisted preference (call before runApp)
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getInt(_prefsKey);
      if (value != null) {
        themeNotifier.value = _themeModeFromInt(value);
      }
    } catch (_) {
      // ignore errors and keep default
    }
  }

  static ThemeMode _themeModeFromInt(int v) {
    switch (v) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static int _intFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      default:
        return 0;
    }
  }

  // Set mode and persist
  static Future<void> setTheme(ThemeMode mode) async {
    themeNotifier.value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsKey, _intFromThemeMode(mode));
    } catch (_) {
      // ignore
    }
  }

  // Backwards-compatible toggle (light <-> dark)
  static Future<void> toggleTheme() async {
    final next = themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setTheme(next);
  }
}
