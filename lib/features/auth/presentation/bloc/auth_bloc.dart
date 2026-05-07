import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecase/login_usecase.dart';
import '../../domain/usecase/register_usecase.dart';
import '../../domain/repo/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../../core/services/secure_storage_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final AuthRepository _repository;
  final SecureStorageService _secureStorage;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required AuthRepository repository,
    required SecureStorageService secureStorage,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _repository = repository,
       _secureStorage = secureStorage,
       super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckStatus>(_onCheckStatus);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<AuthBiometricLoginRequested>(_onBiometricLoginRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _loginUseCase(
      username: event.username,
      password: event.password,
    );
    await result.fold(
      (failure) async => emit(AuthError(failure)),
      (user) async {
        await _secureStorage.saveCredentials(event.username, event.password);
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _registerUseCase(
      username: event.username,
      password: event.password,
      fullName: event.fullName,
    );
    await result.fold(
      (failure) async => emit(AuthError(failure)),
      (user) async {
        await _secureStorage.saveCredentials(event.username, event.password);
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repository.logout();
    await _secureStorage.clearCredentials();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _repository.getCurrentUser();
    result.fold((failure) => emit(AuthUnauthenticated()), (user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      // Keep existing user data while updating
      final result = await _repository.updateProfile(
        fullName: event.fullName,
        avatarUrl: event.avatarUrl,
      );
      
      result.fold(
        (failure) => emit(AuthError(failure)),
        (user) => emit(AuthAuthenticated(user)),
      );
    }
  }

  Future<void> _onBiometricLoginRequested(
    AuthBiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final credentials = await _secureStorage.getCredentials();
    final username = credentials['username'];
    final password = credentials['password'];

    if (username != null && password != null) {
      final result = await _loginUseCase(
        username: username,
        password: password,
      );
      result.fold(
        (failure) => emit(AuthError(failure)),
        (user) => emit(AuthAuthenticated(user)),
      );
    } else {
      emit(AuthError('No saved credentials found'));
    }
  }
}
