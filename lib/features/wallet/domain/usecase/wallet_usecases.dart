import 'package:dartz/dartz.dart';
import '../entities/wallet_entity.dart';
import '../repo/wallet_repository.dart';

class CreateWalletUseCase {
  final WalletRepository repository;

  CreateWalletUseCase(this.repository);

  Future<Either<String, WalletEntity>> call({required String name, required String currency}) {
    return repository.createWallet(name: name, currency: currency);
  }
}

class GetWalletsUseCase {
  final WalletRepository repository;

  GetWalletsUseCase(this.repository);

  Future<Either<String, List<WalletEntity>>> call() {
    return repository.getWallets();
  }
}
