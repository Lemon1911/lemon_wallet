import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/usecase/wallet_usecases.dart';
import '../../domain/usecases/invite_member_usecase.dart';
import '../../domain/usecases/get_pending_invites_usecase.dart';
import '../../domain/usecases/respond_to_invite_usecase.dart';

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

class InviteMember extends WalletEvent {
  final String walletId;
  final String email;
  final String role;
  const InviteMember({required this.walletId, required this.email, required this.role});
  @override
  List<Object?> get props => [walletId, email, role];
}

class LoadInvites extends WalletEvent {}

class RespondToInvite extends WalletEvent {
  final String invitationId;
  final bool accept;
  const RespondToInvite({required this.invitationId, required this.accept});
  @override
  List<Object?> get props => [invitationId, accept];
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
  final List<Map<String, dynamic>> pendingInvites;
  const WalletsLoaded(this.wallets, {this.pendingInvites = const []});
  @override
  List<Object?> get props => [wallets, pendingInvites];
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
  final InviteMemberUseCase _inviteMemberUseCase;
  final GetPendingInvitesUseCase _getPendingInvitesUseCase;
  final RespondToInviteUseCase _respondToInviteUseCase;

  WalletBloc({
    required GetWalletsUseCase getWalletsUseCase,
    required CreateWalletUseCase createWalletUseCase,
    required InviteMemberUseCase inviteMemberUseCase,
    required GetPendingInvitesUseCase getPendingInvitesUseCase,
    required RespondToInviteUseCase respondToInviteUseCase,
  })  : _getWalletsUseCase = getWalletsUseCase,
        _createWalletUseCase = createWalletUseCase,
        _inviteMemberUseCase = inviteMemberUseCase,
        _getPendingInvitesUseCase = getPendingInvitesUseCase,
        _respondToInviteUseCase = respondToInviteUseCase,
        super(WalletInitial()) {
    on<LoadWallets>(_onLoadWallets);
    on<CreateWallet>(_onCreateWallet);
    on<InviteMember>(_onInviteMember);
    on<LoadInvites>(_onLoadInvites);
    on<RespondToInvite>(_onRespondToInvite);
  }

  Future<void> _onLoadWallets(LoadWallets event, Emitter<WalletState> emit) async {
    final currentState = state;
    List<Map<String, dynamic>> currentInvites = [];
    if (currentState is WalletsLoaded) {
      currentInvites = currentState.pendingInvites;
    }

    emit(WalletLoading());
    final result = await _getWalletsUseCase();
    result.fold(
      (failure) => emit(WalletError(failure)),
      (wallets) => emit(WalletsLoaded(wallets, pendingInvites: currentInvites)),
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

  Future<void> _onInviteMember(InviteMember event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    final result = await _inviteMemberUseCase(event.walletId, event.email, event.role);
    result.fold(
      (failure) => emit(WalletError(failure)),
      (_) {
        emit(WalletSuccess());
        add(LoadWallets());
      },
    );
  }

  Future<void> _onLoadInvites(LoadInvites event, Emitter<WalletState> emit) async {
    final currentState = state;
    if (currentState is WalletsLoaded) {
      final result = await _getPendingInvitesUseCase();
      result.fold(
        (failure) => null, // Silently fail for now or handle error
        (invites) => emit(WalletsLoaded(currentState.wallets, pendingInvites: invites)),
      );
    }
  }

  Future<void> _onRespondToInvite(RespondToInvite event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    final result = await _respondToInviteUseCase(event.invitationId, event.accept);
    result.fold(
      (failure) => emit(WalletError(failure)),
      (_) {
        emit(WalletSuccess());
        add(LoadWallets());
        add(LoadInvites());
      },
    );
  }
}
