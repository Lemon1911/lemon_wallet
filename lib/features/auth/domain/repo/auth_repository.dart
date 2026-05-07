import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<String, UserEntity>> login({
    required String username,
    required String password,
  });

  Future<Either<String, UserEntity>> register({
    required String username,
    required String password,
    required String fullName,
  });

  Future<void> logout();

  Future<Either<String, UserEntity>> updateProfile({
    String? fullName,
    String? avatarUrl,
  });

  Future<Either<String, UserEntity?>> getCurrentUser();
}
