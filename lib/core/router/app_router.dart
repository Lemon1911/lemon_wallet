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

class AppRouter {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';
  static const String createWallet = '/create-wallet';
  static const String addTransaction = '/add-transaction';
  static const String scanner = '/scanner';
  static const String editProfile = '/edit-profile';
  static const String budgets = '/budgets';

  static final router = GoRouter(
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
    ],
  );
}
