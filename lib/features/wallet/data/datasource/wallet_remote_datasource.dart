import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<List<WalletModel>> getWallets();
  Future<WalletModel> createWallet({required String name, required String currency});
  Future<void> deleteWallet(String walletId);
  Future<void> inviteMember(String walletId, String email, String role);
  Future<List<Map<String, dynamic>>> getPendingInvites();
  Future<void> respondToInvite(String invitationId, bool accept);
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
  Future<void> inviteMember(String walletId, String email, String role) async {
    await supabaseClient.from('wallet_invitations').insert({
      'wallet_id': walletId,
      'invited_email': email,
      'role': role,
      'status': 'pending',
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingInvites() async {
    final response = await supabaseClient
        .from('wallet_invitations')
        .select('*, wallets(name, currency)')
        .eq('status', 'pending');
    return response;
  }

  @override
  Future<void> respondToInvite(String invitationId, bool accept) async {
    if (accept) {
      await supabaseClient.rpc('accept_wallet_invitation', params: {
        'invitation_id': invitationId,
      });
    } else {
      await supabaseClient
          .from('wallet_invitations')
          .update({'status': 'rejected'})
          .eq('id', invitationId);
    }
  }
}
