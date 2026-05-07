import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<List<WalletModel>> getWallets();
  Future<WalletModel> createWallet({required String name, required String currency});
  Future<void> deleteWallet(String walletId);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final SupabaseClient supabaseClient;

  WalletRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<WalletModel>> getWallets() async {
    final response = await supabaseClient.from('wallets').select();
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
}
