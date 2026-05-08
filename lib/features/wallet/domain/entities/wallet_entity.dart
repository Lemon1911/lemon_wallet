import 'package:equatable/equatable.dart';
import 'wallet_member_entity.dart';

class WalletEntity extends Equatable {
  final String id;
  final String name;
  final String currency;
  final String ownerId;
  final DateTime createdAt;
  final List<WalletMemberEntity> members;

  const WalletEntity({
    required this.id,
    required this.name,
    required this.currency,
    required this.ownerId,
    required this.createdAt,
    this.members = const [],
  });

  @override
  List<Object?> get props => [id, name, currency, ownerId, createdAt, members];
}
