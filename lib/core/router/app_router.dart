import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/main_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/wallet/presentation/screens/create_wallet_screen.dart';
import '../../features/transactions/presentation/screens/add_transaction_screen.dart';
import '../../features/scanner/presentation/screens/scanner_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/budget/presentation/screens/budget_screen.dart';
import '../../features/insights/presentation/screens/ai_chat_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/goals/presentation/screens/add_goal_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';
  static const String createWallet = '/create-wallet';
  static const String addTransaction = '/add-transaction';
  static const String scanner = '/scanner';
  static const String editProfile = '/edit-profile';
  static const String budgets = '/budgets';
  static const String aiChat = '/ai-chat';
  static const String settings = '/settings';
  static const String goals = '/goals';
  static const String addGoal = '/add-goal';

  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: splash,
    routes: [
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: home, builder: (context, state) => const MainScreen()),
      GoRoute(
        path: createWallet,
        builder: (context, state) => const CreateWalletScreen(),
      ),
      GoRoute(
        path: addTransaction,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final walletId = extra['walletId'] as String;
          final initialType = extra['type'];
          final initialAmount = extra['initialAmount'] as double?;
          final initialNote = extra['initialNote'] as String?;
          return AddTransactionScreen(
            walletId: walletId, 
            initialType: initialType,
            initialAmount: initialAmount,
            initialNote: initialNote,
          );
        },
      ),
      GoRoute(
        path: scanner,
        builder: (context, state) {
          final walletId = state.extra as String;
          return ScannerScreen(walletId: walletId);
        },
      ),
      GoRoute(
        path: editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: budgets,
        builder: (context, state) => const BudgetScreen(),
      ),
      GoRoute(
        path: aiChat,
        builder: (context, state) => const AiChatScreen(),
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: goals,
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: addGoal,
        builder: (context, state) => const AddGoalScreen(),
      ),
    ],
  );
}
