import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions({required String walletId});
  Future<List<CategoryModel>> getCategories();

  Future<TransactionModel> addTransaction({
    required String walletId,
    required String categoryId,
    required double amount,
    required TransactionType type,
    required String note,
    required DateTime transactionDate,
    String? receiptUrl,
  });

  Future<void> deleteTransaction(String transactionId);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final SupabaseClient supabaseClient;

  TransactionRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await supabaseClient.from('categories').select();
    return (response as List).map((json) => CategoryModel.fromJson(json)).toList();
  }

  @override
  Future<List<TransactionModel>> getTransactions({required String walletId}) async {
    final response = await supabaseClient
        .from('transactions')
        .select()
        .eq('wallet_id', walletId)
        .order('transaction_date', ascending: false);

    return (response as List).map((json) => TransactionModel.fromJson(json)).toList();
  }

  @override
  Future<TransactionModel> addTransaction({
    required String walletId,
    required String categoryId,
    required double amount,
    required TransactionType type,
    required String note,
    required DateTime transactionDate,
    String? receiptUrl,
  }) async {
    final userId = supabaseClient.auth.currentUser!.id;

    final response = await supabaseClient.from('transactions').insert({
      'wallet_id': walletId,
      'category_id': categoryId,
      'user_id': userId,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'note': note,
      'receipt_url': receiptUrl,
      'transaction_date': transactionDate.toIso8601String(),
    }).select().single();

    return TransactionModel.fromJson(response);
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    await supabaseClient.from('transactions').delete().eq('id', transactionId);
  }
}
