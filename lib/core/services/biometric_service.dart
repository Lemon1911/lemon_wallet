import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<bool> authenticate() async {
    try {
      if (!await isBiometricAvailable()) return false;

      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access your wallet',
      );
    } catch (e) {
      return false;
    }
  }
}
