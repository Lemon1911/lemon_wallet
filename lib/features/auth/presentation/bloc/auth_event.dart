import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginRequested({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String password;
  final String fullName;

  const AuthRegisterRequested({
    required this.username,
    required this.password,
    required this.fullName,
  });

  @override
  List<Object?> get props => [username, password, fullName];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}

class AuthBiometricLoginRequested extends AuthEvent {}

class UpdateProfileRequested extends AuthEvent {
  final String? fullName;
  final String? avatarUrl;

  const UpdateProfileRequested({this.fullName, this.avatarUrl});

  @override
  List<Object?> get props => [fullName, avatarUrl];
}
