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
import '../../features/wallet/presentation/bloc/wallet_bloc.dart';
import '../../features/scanner/domain/repo/scanner_repository.dart';
import '../../features/scanner/data/repoimpl/scanner_repository_impl.dart';
import '../../features/scanner/presentation/bloc/scanner_bloc.dart';
import '../services/biometric_service.dart';
final sl = GetIt.instance;

Future<void> init() async {
  // Services
  sl.registerLazySingleton(() => BiometricService());

  // Features - Auth

  // Bloc
  sl.registerFactory(
    () => AuthBloc(loginUseCase: sl(), registerUseCase: sl(), repository: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(sl()),
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
    () => TransactionRepositoryImpl(sl()),
  );

  // Features - Wallets
  sl.registerFactory(() => WalletBloc(
        getWalletsUseCase: sl(),
        createWalletUseCase: sl(),
      ));
  sl.registerLazySingleton(() => CreateWalletUseCase(sl()));
  sl.registerLazySingleton(() => GetWalletsUseCase(sl()));
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(sl()),
  );

  // Features - Scanner
  sl.registerFactory(() => ScannerBloc(scannerRepository: sl()));
  sl.registerLazySingleton<ScannerRepository>(() => ScannerRepositoryImpl());

  // External
  sl.registerLazySingleton(() => Supabase.instance.client);
}
