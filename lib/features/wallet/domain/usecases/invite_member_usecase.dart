import 'package:dartz/dartz.dart';
import '../repo/wallet_repository.dart';

class InviteMemberUseCase {
  final WalletRepository repository;

  InviteMemberUseCase(this.repository);

  Future<Either<String, void>> call(String walletId, String emailOrUsername, String role) {
    return repository.inviteMember(walletId, emailOrUsername, role);
  }
}
