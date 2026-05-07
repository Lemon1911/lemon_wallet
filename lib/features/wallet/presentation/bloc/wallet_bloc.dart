import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/usecase/wallet_usecases.dart';

// Events
abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object?> get props => [];
}

class LoadWallets extends WalletEvent {}

class CreateWallet extends WalletEvent {
  final String name;
  final String currency;
  const CreateWallet({required this.name, required this.currency});
  @override
  List<Object?> get props => [name, currency];
}

// States
abstract class WalletState extends Equatable {
  const WalletState();
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}
class WalletLoading extends WalletState {}
class WalletsLoaded extends WalletState {
  final List<WalletEntity> wallets;
  const WalletsLoaded(this.wallets);
  @override
  List<Object?> get props => [wallets];
}
class WalletSuccess extends WalletState {}
class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletsUseCase _getWalletsUseCase;
  final CreateWalletUseCase _createWalletUseCase;

  WalletBloc({
    required GetWalletsUseCase getWalletsUseCase,
    required CreateWalletUseCase createWalletUseCase,
  })  : _getWalletsUseCase = getWalletsUseCase,
        _createWalletUseCase = createWalletUseCase,
        super(WalletInitial()) {
    on<LoadWallets>(_onLoadWallets);
    on<CreateWallet>(_onCreateWallet);
  }

  Future<void> _onLoadWallets(LoadWallets event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    final result = await _getWalletsUseCase();
    result.fold(
      (failure) => emit(WalletError(failure)),
      (wallets) => emit(WalletsLoaded(wallets)),
    );
  }

  Future<void> _onCreateWallet(CreateWallet event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    final result = await _createWalletUseCase(name: event.name, currency: event.currency);
    result.fold(
      (failure) => emit(WalletError(failure)),
      (_) => emit(WalletSuccess()),
    );
  }
}
