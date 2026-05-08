import 'package:equatable/equatable.dart';

enum WalletRole { owner, admin, viewer }

class WalletMemberEntity extends Equatable {
  final String walletId;
  final String userId;
  final String? fullName;
  final String? username;
  final WalletRole role;

  const WalletMemberEntity({
    required this.walletId,
    required this.userId,
    this.fullName,
    this.username,
    required this.role,
  });

  @override
  List<Object?> get props => [walletId, userId, fullName, username, role];
}
