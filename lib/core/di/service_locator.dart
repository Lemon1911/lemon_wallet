import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/data/datasource/auth_remote_datasource.dart';
import '../../features/auth/data/repoimpl/auth_repository_impl.dart';
import '../../features/auth/domain/repo/auth_repository.dart';
import '../../features/auth/domain/usecase/login_usecase.dart';
import '../../features/auth/domain/usecase/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/transactions/data/datasource/transaction_remote_datasource.dart';
import '../../features/transactions/data/repoimpl/transaction_repository_impl.dart';
import '../../features/transactions/domain/repo/transaction_repository.dart';
import '../../features/transactions/domain/usecase/transaction_usecases.dart';
import '../../features/transactions/presentation/bloc/transaction_bloc.dart';
import '../../features/wallet/data/datasource/wallet_remote_datasource.dart';
import '../../features/wallet/data/repoimpl/wallet_repository_impl.dart';
import '../../features/wallet/domain/repo/wallet_repository.dart';
import '../../features/wallet/domain/usecase/wallet_usecases.dart';
import '../../features/wallet/domain/usecases/invite_member_usecase.dart';
import '../../features/wallet/presentation/bloc/wallet_bloc.dart';
import '../../features/scanner/domain/repo/scanner_repository.dart';
import '../../features/scanner/data/repoimpl/scanner_repository_impl.dart';
import '../../features/scanner/presentation/bloc/scanner_bloc.dart';
import '../services/biometric_service.dart';
import '../services/secure_storage_service.dart';
import '../../features/transactions/data/datasource/transaction_local_datasource.dart';
import '../../features/wallet/data/datasource/wallet_local_datasource.dart';
import '../database/database_helper.dart';
import '../services/currency_service.dart';

import '../../features/budget/data/datasources/budget_local_datasource.dart';
import '../../features/budget/data/datasources/budget_remote_datasource.dart';
import '../../features/budget/data/repoimpl/budget_repository_impl.dart';
import '../../features/budget/domain/repositories/budget_repository.dart';
import '../../features/budget/domain/usecases/budget_usecases.dart';
import '../../features/budget/presentation/bloc/budget_bloc.dart';

import '../theme/theme_bloc.dart';
import '../theme/theme_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Database & Cache
  sl.registerLazySingleton(() => DatabaseHelper());
  sl.registerLazySingleton(() => ThemeService());

  // Services
  sl.registerLazySingleton(() => BiometricService());
  sl.registerLazySingleton(() => SecureStorageService());
  sl.registerLazySingleton(() => CurrencyService());

  // Features - Theme
  sl.registerFactory(() => ThemeBloc(themeService: sl()));

  // Features - Auth
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      repository: sl(),
      secureStorage: sl(),
    ),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Features - Transactions
  sl.registerFactory(() => TransactionBloc(
        getTransactionsUseCase: sl(),
        addTransactionUseCase: sl(),
        getCategoriesUseCase: sl(),
      ));
  sl.registerLazySingleton(() => AddTransactionUseCase(sl()));
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<TransactionLocalDataSource>(
    () => TransactionLocalDataSourceImpl(sl()),
  );

  // Features - Wallets
  sl.registerFactory(() => WalletBloc(
        getWalletsUseCase: sl(),
        createWalletUseCase: sl(),
        inviteMemberUseCase: sl(),
      ));
  sl.registerLazySingleton(() => CreateWalletUseCase(sl()));
  sl.registerLazySingleton(() => GetWalletsUseCase(sl()));
  sl.registerLazySingleton(() => InviteMemberUseCase(sl()));
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<WalletLocalDataSource>(
    () => WalletLocalDataSourceImpl(sl()),
  );

  // Features - Scanner
  sl.registerFactory(() => ScannerBloc(scannerRepository: sl()));
  sl.registerLazySingleton<ScannerRepository>(() => ScannerRepositoryImpl());

  // Features - Budget
  sl.registerFactory(() => BudgetBloc(
        getBudgetsUseCase: sl(),
        addBudgetUseCase: sl(),
        deleteBudgetUseCase: sl(),
      ));
  sl.registerLazySingleton(() => GetBudgetsUseCase(sl()));
  sl.registerLazySingleton(() => AddBudgetUseCase(sl()));
  sl.registerLazySingleton(() => DeleteBudgetUseCase(sl()));
  sl.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      supabaseClient: sl(),
    ),
  );
  sl.registerLazySingleton<BudgetLocalDataSource>(
    () => BudgetLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BudgetRemoteDataSource>(
    () => BudgetRemoteDataSourceImpl(sl()),
  );

  // External
  sl.registerLazySingleton(() => Supabase.instance.client);
}
