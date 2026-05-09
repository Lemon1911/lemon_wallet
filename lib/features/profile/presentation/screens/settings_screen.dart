import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_components.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/di/service_locator.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _prefs = sl<PreferenceService>();

  late bool _smsEnabled;
  late bool _notificationsEnabled;
  late bool _autoConfirmEnabled;
  late String _currency;

  @override
  void initState() {
    super.initState();
    _smsEnabled = _prefs.isSmsEnabled;
    _notificationsEnabled = _prefs.isNotificationsEnabled;
    _autoConfirmEnabled = _prefs.isAutoConfirmEnabled;
    _currency = _prefs.currency;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Automation'),
            const SizedBox(height: 16),
            _buildToggleTile(
              icon: Icons.sms_rounded,
              title: 'SMS Tracking',
              subtitle: 'Automatically detect expenses from SMS',
              value: _smsEnabled,
              onChanged: (val) {
                setState(() => _smsEnabled = val);
                _prefs.setSmsEnabled(val);
              },
            ),
            const SizedBox(height: 12),
            _buildToggleTile(
              icon: Icons.notifications_active_rounded,
              title: 'Push Notifications',
              subtitle: 'Alerts for new transactions',
              value: _notificationsEnabled,
              onChanged: (val) {
                setState(() => _notificationsEnabled = val);
                _prefs.setNotificationsEnabled(val);
              },
            ),
            const SizedBox(height: 12),
            _buildToggleTile(
              icon: Icons.offline_bolt_rounded,
              title: 'Auto-Confirm',
              subtitle: 'Automatically approve small transactions',
              value: _autoConfirmEnabled,
              onChanged: (val) {
                setState(() => _autoConfirmEnabled = val);
                _prefs.setAutoConfirmEnabled(val);
              },
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Preferences'),
            const SizedBox(height: 16),
            _buildDropdownTile(
              icon: Icons.payments_rounded,
              title: 'Preferred Currency',
              value: _currency,
              items: ['USD', 'EUR', 'GBP', 'EGP', 'SAR'],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _currency = val);
                  _prefs.setCurrency(val);
                }
              },
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Security'),
            const SizedBox(height: 16),
            _buildActionTile(
              icon: Icons.fingerprint_rounded,
              title: 'Biometric Lock',
              onTap: () {
                // Already handled in login but could add a toggle here
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          DropdownButton<String>(
            value: value,
            dropdownColor: AppColors.bgDark,
            underline: const SizedBox(),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white70, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }
}
