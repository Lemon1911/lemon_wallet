import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repo/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<String, UserEntity>> call({
    required String username,
    required String password,
    required String fullName,
  }) {
    return repository.register(
      username: username,
      password: password,
      fullName: fullName,
    );
  }
}
