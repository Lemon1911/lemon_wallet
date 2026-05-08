import 'package:dartz/dartz.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repo/wallet_repository.dart';
import '../datasource/wallet_remote_datasource.dart';

import '../datasource/wallet_local_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;
  final WalletLocalDataSource localDataSource;

  WalletRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<String, List<WalletEntity>>> getWallets() async {
    try {
      final wallets = await remoteDataSource.getWallets();
      await localDataSource.cacheWallets(wallets);
      return Right(wallets);
    } catch (e) {
      // Fallback to local data
      final localWallets = await localDataSource.getWallets();
      if (localWallets.isNotEmpty) {
        return Right(localWallets);
      }
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, WalletEntity>> createWallet({required String name, required String currency}) async {
    try {
      final wallet = await remoteDataSource.createWallet(name: name, currency: currency);
      await localDataSource.saveWallet(wallet);
      return Right(wallet);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteWallet(String walletId) async {
    try {
      await remoteDataSource.deleteWallet(walletId);
      await localDataSource.deleteWallet(walletId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> inviteMember(String walletId, String emailOrUsername, String role) async {
    try {
      await remoteDataSource.inviteMember(walletId, emailOrUsername, role);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
