import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/di/service_locator.dart' as di;
import 'core/services/notification_service.dart';
import 'core/services/sms_receiver_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/budget/presentation/bloc/budget_bloc.dart';
import 'features/insights/presentation/bloc/insights_bloc.dart';
import 'features/scanner/presentation/bloc/scanner_bloc.dart';
import 'features/transactions/presentation/bloc/transaction_bloc.dart';
import 'features/wallet/presentation/bloc/wallet_bloc.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();
  await NotificationService.init();
  await SmsReceiverService.startListening();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<ThemeBloc>()..add(LoadThemeEvent()),
        ),
        BlocProvider(
          create: (context) => di.sl<AuthBloc>()..add(AuthCheckStatus()),
        ),
        BlocProvider(
          create: (context) => di.sl<WalletBloc>()..add(LoadWallets()),
        ),
        BlocProvider(create: (context) => di.sl<TransactionBloc>()),
        BlocProvider(create: (context) => di.sl<BudgetBloc>()),
        BlocProvider(create: (context) => di.sl<ScannerBloc>()),
        BlocProvider(create: (context) => di.sl<InsightsBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: "LemonWallet",
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRouter.router,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ar')],
          );
        },
      ),
    );
  }
}
