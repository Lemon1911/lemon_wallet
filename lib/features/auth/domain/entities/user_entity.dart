import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
  });

  UserEntity copyWith({
    String? fullName,
    String? avatarUrl,
  }) {
    return UserEntity(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, email, fullName, avatarUrl];
}
