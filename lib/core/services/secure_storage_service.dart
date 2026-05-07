import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyUsername = 'username';
  static const String _keyPassword = 'password';
  static const String _keyBiometricsEnabled = 'biometrics_enabled';

  Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: _keyUsername, value: username);
    await _storage.write(key: _keyPassword, value: password);
  }

  Future<Map<String, String?>> getCredentials() async {
    final username = await _storage.read(key: _keyUsername);
    final password = await _storage.read(key: _keyPassword);
    return {
      'username': username,
      'password': password,
    };
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: _keyUsername);
    await _storage.delete(key: _keyPassword);
    await _storage.delete(key: _keyBiometricsEnabled);
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await _storage.write(key: _keyBiometricsEnabled, value: enabled.toString());
  }

  Future<bool> isBiometricsEnabled() async {
    final value = await _storage.read(key: _keyBiometricsEnabled);
    return value == 'true';
  }
}
