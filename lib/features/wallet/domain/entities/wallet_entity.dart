import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final String id;
  final String name;
  final String currency;
  final String ownerId;
  final DateTime createdAt;

  const WalletEntity({
    required this.id,
    required this.name,
    required this.currency,
    required this.ownerId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, currency, ownerId, createdAt];
}
