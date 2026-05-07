import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repo/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<String, UserEntity>> call({
    required String username,
    required String password,
  }) {
    return repository.login(username: username, password: password);
  }
}
