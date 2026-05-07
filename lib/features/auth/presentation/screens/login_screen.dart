import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lemon_wallet/core/router/app_router.dart';
import 'package:lemon_wallet/core/widgets/custom_components.dart';
import 'package:lemon_wallet/core/theme/app_colors.dart';
import 'package:lemon_wallet/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lemon_wallet/features/auth/presentation/bloc/auth_event.dart';
import 'dart:ui';
import 'package:lemon_wallet/features/auth/presentation/bloc/auth_state.dart';
import 'package:lemon_wallet/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go(AppRouter.home);
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              // Using a post-frame callback to avoid navigation during build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) context.go(AppRouter.home);
              });
              return const Center(child: CircularProgressIndicator());
            }
            return Container(
          color: AppColors.bgDark, // Deep Midnight Blue background
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Logo
                        Image.asset('assets/images/logo_cyan.png', height: 120)
                            .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true),
                            )
                            .shimmer(
                              duration: 2.seconds,
                              color: AppColors.primary.withValues(alpha: 0.3),
                            )
                            .animate() // Entrance
                            .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                            .scale(begin: const Offset(0.8, 0.8)),

                        const SizedBox(height: 32),

                        // Glassmorphic Card
                        ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 16,
                                  sigmaY: 16,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: AppColors.glassFill,
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: AppColors.glassBorder,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        l10n.login,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                      ),
                                      const SizedBox(height: 32),
                                      CustomTextField(
                                        key: const Key('username_field'),
                                        controller: _usernameController,
                                        labelText: 'Username',
                                        prefixIcon: Icons.person_outline,
                                        validator: (value) => value!.isEmpty
                                            ? 'Please enter username'
                                            : null,
                                      ),
                                      const SizedBox(height: 16),
                                      CustomTextField(
                                        key: const Key('password_field'),
                                        controller: _passwordController,
                                        labelText: l10n.password,
                                        prefixIcon: Icons.lock_outline,
                                        isPassword: true,
                                        validator: (value) => value!.isEmpty
                                            ? 'Please enter password'
                                            : null,
                                      ),
                                      const SizedBox(height: 32),
                                      BlocBuilder<AuthBloc, AuthState>(
                                        builder: (context, state) {
                                          return Column(
                                            children: [
                                              CustomButton(
                                                key: const Key('login_button'),
                                                text: l10n.login,
                                                isLoading: state is AuthLoading,
                                                onPressed: () {
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    context
                                                        .read<AuthBloc>()
                                                        .add(
                                                          AuthLoginRequested(
                                                            username:
                                                                _usernameController
                                                                    .text
                                                                    .trim(),
                                                            password:
                                                                _passwordController
                                                                    .text
                                                                    .trim(),
                                                          ),
                                                        );
                                                  }
                                                },
                                              ),
                                              const SizedBox(height: 16),
                                              IconButton(
                                                onPressed: () {
                                                  context.read<AuthBloc>().add(
                                                      AuthBiometricLoginRequested());
                                                },
                                                icon: const Icon(
                                                    Icons.fingerprint,
                                                    size: 48,
                                                    color: AppColors.primary),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 800.ms, delay: 200.ms)
                            .slideY(begin: 0.1, curve: Curves.easeOut),

                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () => context.push(AppRouter.register),
                          child: Text(
                            l10n.dontHaveAccount,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  ),
);
  }
}
