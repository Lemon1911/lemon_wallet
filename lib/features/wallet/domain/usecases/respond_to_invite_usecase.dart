import 'package:dartz/dartz.dart';
import '../repo/wallet_repository.dart';

class RespondToInviteUseCase {
  final WalletRepository repository;

  RespondToInviteUseCase(this.repository);

  Future<Either<String, void>> call(String invitationId, bool accept) async {
    return await repository.respondToInvite(invitationId, accept);
  }
}
