import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<String, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<String, UserEntity>> register({
    required String email,
    required String password,
    required String fullName,
  });

  Future<void> logout();

  Future<Either<String, UserEntity?>> getCurrentUser();
}
