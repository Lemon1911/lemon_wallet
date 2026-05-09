import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  final SharedPreferences _prefs;

  PreferenceService(this._prefs);

  static const String _keySmsEnabled = 'sms_tracking_enabled';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyAutoConfirmEnabled = 'auto_confirm_enabled';
  static const String _keyCurrency = 'preferred_currency';

  bool get isSmsEnabled => _prefs.getBool(_keySmsEnabled) ?? true;
  Future<void> setSmsEnabled(bool value) => _prefs.setBool(_keySmsEnabled, value);

  bool get isNotificationsEnabled => _prefs.getBool(_keyNotificationsEnabled) ?? true;
  Future<void> setNotificationsEnabled(bool value) => _prefs.setBool(_keyNotificationsEnabled, value);

  bool get isAutoConfirmEnabled => _prefs.getBool(_keyAutoConfirmEnabled) ?? false;
  Future<void> setAutoConfirmEnabled(bool value) => _prefs.setBool(_keyAutoConfirmEnabled, value);

  String get currency => _prefs.getString(_keyCurrency) ?? 'USD';
  Future<void> setCurrency(String value) => _prefs.setString(_keyCurrency, value);
}
