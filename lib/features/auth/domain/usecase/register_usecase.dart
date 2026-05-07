import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repo/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<String, UserEntity>> call({
    required String email,
    required String password,
    required String fullName,
  }) {
    return repository.register(
      email: email,
      password: password,
      fullName: fullName,
    );
  }
}
