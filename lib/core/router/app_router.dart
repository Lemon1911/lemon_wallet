import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/main_screen.dart';

import '../../features/wallet/presentation/screens/create_wallet_screen.dart';

import '../../features/transactions/presentation/screens/add_transaction_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';
  static const String createWallet = '/create-wallet';
  static const String addTransaction = '/add-transaction';

  static final router = GoRouter(
    initialLocation: login,
    routes: [
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
          final walletId = state.extra as String;
          return AddTransactionScreen(walletId: walletId);
        },
      ),
    ],
  );
}
