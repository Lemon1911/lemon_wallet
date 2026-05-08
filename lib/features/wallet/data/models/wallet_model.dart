import '../../domain/entities/wallet_entity.dart';
import 'wallet_member_model.dart';

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.id,
    required super.name,
    required super.currency,
    required super.ownerId,
    required super.createdAt,
    super.members,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Unnamed Wallet').toString(),
      currency: (json['currency'] ?? 'USD').toString(),
      ownerId: (json['owner_id'] ?? json['user_id'] ?? '').toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      members: json['wallet_members'] != null
          ? (json['wallet_members'] as List)
              .map((m) => WalletMemberModel.fromJson(m))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currency': currency,
      'user_id': ownerId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
