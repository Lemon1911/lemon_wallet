import 'package:dartz/dartz.dart';
import '../repo/wallet_repository.dart';

class GetPendingInvitesUseCase {
  final WalletRepository repository;

  GetPendingInvitesUseCase(this.repository);

  Future<Either<String, List<Map<String, dynamic>>>> call() async {
    return await repository.getPendingInvites();
  }
}
