import 'package:dartz/dartz.dart';
import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<Either<String, List<WalletEntity>>> getWallets();
  Future<Either<String, WalletEntity>> createWallet({required String name, required String currency});
  Future<Either<String, void>> deleteWallet(String walletId);
}
