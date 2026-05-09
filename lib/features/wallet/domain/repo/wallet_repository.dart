import 'package:dartz/dartz.dart';
import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<Either<String, List<WalletEntity>>> getWallets();
  Future<Either<String, WalletEntity>> createWallet({required String name, required String currency});
  Future<Either<String, void>> deleteWallet(String walletId);
  Future<Either<String, void>> inviteMember(String walletId, String email, String role);
  Future<Either<String, List<Map<String, dynamic>>>> getPendingInvites();
  Future<Either<String, void>> respondToInvite(String invitationId, bool accept);
}
