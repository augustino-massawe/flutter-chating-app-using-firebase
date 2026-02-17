import 'package:shared_preferences/shared_preferences.dart';

class PrivacyService {
  static const _kShowOnline = 'privacy_show_online';
  static const _kLastSeen = 'privacy_last_seen';
  static const _kReadReceipts = 'privacy_read_receipts';
  static const _kAllowGroups = 'privacy_allow_groups';

  static Future<bool> getShowOnline() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kShowOnline) ?? true;
  }

  static Future<void> setShowOnline(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kShowOnline, v);
  }

  static Future<bool> getLastSeen() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kLastSeen) ?? true;
  }

  static Future<void> setLastSeen(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kLastSeen, v);
  }

  static Future<bool> getReadReceipts() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kReadReceipts) ?? true;
  }

  static Future<void> setReadReceipts(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kReadReceipts, v);
  }

  static Future<bool> getAllowGroups() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kAllowGroups) ?? true;
  }

  static Future<void> setAllowGroups(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kAllowGroups, v);
  }
}
