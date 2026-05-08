import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<List<WalletModel>> getWallets();
  Future<WalletModel> createWallet({required String name, required String currency});
  Future<void> deleteWallet(String walletId);
  Future<void> inviteMember(String walletId, String emailOrUsername, String role);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final SupabaseClient supabaseClient;

  WalletRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<WalletModel>> getWallets() async {
    final response = await supabaseClient
        .from('wallets')
        .select('*, wallet_members(*, users(*))');
    return (response as List).map((json) => WalletModel.fromJson(json)).toList();
  }

  @override
  Future<WalletModel> createWallet({required String name, required String currency}) async {
    final userId = supabaseClient.auth.currentUser!.id;
    final response = await supabaseClient.from('wallets').insert({
      'name': name,
      'currency': currency,
      'owner_id': userId,
    }).select().single();
    
    return WalletModel.fromJson(response);
  }

  @override
  Future<void> deleteWallet(String walletId) async {
    await supabaseClient.from('wallets').delete().eq('id', walletId);
  }

  @override
  Future<void> inviteMember(String walletId, String emailOrUsername, String role) async {
    // 1. Find the user
    final userResponse = await supabaseClient
        .from('users')
        .select('id')
        .or('username.eq.$emailOrUsername,full_name.eq.$emailOrUsername') // Simplified lookup
        .single();
    
    final targetUserId = userResponse['id'];

    // 2. Insert into wallet_members
    await supabaseClient.from('wallet_members').insert({
      'wallet_id': walletId,
      'user_id': targetUserId,
      'role': role,
    });
  }
}
