import 'package:dartz/dartz.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repo/wallet_repository.dart';
import '../datasource/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, List<WalletEntity>>> getWallets() async {
    try {
      final wallets = await remoteDataSource.getWallets();
      return Right(wallets);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, WalletEntity>> createWallet({required String name, required String currency}) async {
    try {
      final wallet = await remoteDataSource.createWallet(name: name, currency: currency);
      return Right(wallet);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteWallet(String walletId) async {
    try {
      await remoteDataSource.deleteWallet(walletId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
