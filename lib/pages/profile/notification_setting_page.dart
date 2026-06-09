import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingPage extends StatefulWidget {
  const NotificationSettingPage({super.key});

  @override
  State<NotificationSettingPage> createState() => _NotificationSettingPageState();
}

class _NotificationSettingPageState extends State<NotificationSettingPage> {
  bool _studyReminder = true;
  bool _classUpdate = true;
  bool _promo = false;
  bool _discussion = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _studyReminder = prefs.getBool('pref_study_reminder') ?? true;
      _classUpdate = prefs.getBool('pref_class_update') ?? true;
      _promo = prefs.getBool('pref_promo') ?? false;
      _discussion = prefs.getBool('pref_discussion') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _togglePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    setState(() {
      switch (key) {
        case 'pref_study_reminder':
          _studyReminder = value;
          break;
        case 'pref_class_update':
          _classUpdate = value;
          break;
        case 'pref_promo':
          _promo = value;
          break;
        case 'pref_discussion':
          _discussion = value;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2B2B2F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification Settings',
          style: TextStyle(
            color: Color(0xFF2B2B2F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6B58E6),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSwitchTile(
                            icon: Icons.alarm,
                            title: 'Pengingat Belajar',
                            subtitle: 'Pengingat harian untuk membantu Anda belajar tepat waktu.',
                            value: _studyReminder,
                            onChanged: (val) => _togglePreference('pref_study_reminder', val),
                          ),
                          const Divider(height: 1),
                          _buildSwitchTile(
                            icon: Icons.class_outlined,
                            title: 'Update Kelas',
                            subtitle: 'Notifikasi saat ada materi, tugas, atau kuis baru dirilis.',
                            value: _classUpdate,
                            onChanged: (val) => _togglePreference('pref_class_update', val),
                          ),
                          const Divider(height: 1),
                          _buildSwitchTile(
                            icon: Icons.local_offer_outlined,
                            title: 'Diskon & Promosi',
                            subtitle: 'Info flash sale kelas baru, voucher, dan penawaran belajar.',
                            value: _promo,
                            onChanged: (val) => _togglePreference('pref_promo', val),
                          ),
                          const Divider(height: 1),
                          _buildSwitchTile(
                            icon: Icons.forum_outlined,
                            title: 'Aktivitas Diskusi',
                            subtitle: 'Pemberitahuan jika ada yang membalas komentar Anda di forum.',
                            value: _discussion,
                            onChanged: (val) => _togglePreference('pref_discussion', val),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SwitchListTile.adaptive(
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EDFF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF6B58E6), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2B2B2F),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        activeThumbColor: const Color(0xFF6B58E6),
        activeTrackColor: const Color(0xFF8B7AFF).withValues(alpha: 0.3),
        value: value,
        onChanged: onChanged,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
