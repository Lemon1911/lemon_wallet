import '../../domain/entities/wallet_member_entity.dart';

class WalletMemberModel extends WalletMemberEntity {
  const WalletMemberModel({
    required super.walletId,
    required super.userId,
    super.fullName,
    super.username,
    required super.role,
  });

  factory WalletMemberModel.fromJson(Map<String, dynamic> json) {
    return WalletMemberModel(
      walletId: json['wallet_id'].toString(),
      userId: json['user_id'].toString(),
      fullName: json['users']?['full_name']?.toString(),
      username: json['users']?['username']?.toString(),
      role: _parseRole(json['role']?.toString()),
    );
  }

  static WalletRole _parseRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'owner':
        return WalletRole.owner;
      case 'admin':
        return WalletRole.admin;
      case 'viewer':
      default:
        return WalletRole.viewer;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_id': walletId,
      'user_id': userId,
      'role': role.name,
    };
  }
}
