import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/biometric_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final secureStorage = sl<SecureStorageService>();
    final biometricService = sl<BiometricService>();
    
    final credentials = await secureStorage.getCredentials();
    final hasCredentials = credentials['username'] != null && credentials['password'] != null;

    if (!mounted) return;

    if (hasCredentials) {
      final isBiometricAvailable = await biometricService.isBiometricAvailable();
      if (isBiometricAvailable) {
        try {
          final authenticated = await biometricService.authenticate();
          if (authenticated) {
            if (!mounted) return;
            context.read<AuthBloc>().add(AuthBiometricLoginRequested());
            return;
          }
        } catch (e) {
          debugPrint('Biometric authentication error: $e');
        }
      }
    }
    
    // Default to login screen if no credentials or biometric failed/cancelled
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/');
        } else if (state is AuthError) {
          context.go('/login');
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
