import 'package:flutter/material.dart';
import '../services/privacy_service.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _showOnline = true;
  bool _lastSeen = true;
  bool _readReceipts = true;
  bool _allowGroups = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s1 = await PrivacyService.getShowOnline();
    final s2 = await PrivacyService.getLastSeen();
    final s3 = await PrivacyService.getReadReceipts();
    final s4 = await PrivacyService.getAllowGroups();
    if (!mounted) return;
    setState(() {
      _showOnline = s1;
      _lastSeen = s2;
      _readReceipts = s3;
      _allowGroups = s4;
    });
  }

  Future<void> _updateShowOnline(bool v) async {
    setState(() => _showOnline = v);
    await PrivacyService.setShowOnline(v);
  }

  Future<void> _updateLastSeen(bool v) async {
    setState(() => _lastSeen = v);
    await PrivacyService.setLastSeen(v);
  }

  Future<void> _updateReadReceipts(bool v) async {
    setState(() => _readReceipts = v);
    await PrivacyService.setReadReceipts(v);
  }

  Future<void> _updateAllowGroups(bool v) async {
    setState(() => _allowGroups = v);
    await PrivacyService.setAllowGroups(v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Show online status'),
                  subtitle: const Text('Allow others to see when you are online'),
                  value: _showOnline,
                  onChanged: _updateShowOnline,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Share last seen'),
                  subtitle: const Text('Share your last active time with contacts'),
                  value: _lastSeen,
                  onChanged: _updateLastSeen,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Read receipts'),
                  subtitle: const Text('Allow others to see when you read messages'),
                  value: _readReceipts,
                  onChanged: _updateReadReceipts,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Allow adding to groups'),
                  subtitle: const Text('Control whether others can add you to groups'),
                  value: _allowGroups,
                  onChanged: _updateAllowGroups,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
