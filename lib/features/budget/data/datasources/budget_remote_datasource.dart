import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/budget_model.dart';

abstract class BudgetRemoteDataSource {
  Future<List<BudgetModel>> getBudgets();
  Future<void> saveBudget(BudgetModel budget);
  Future<void> deleteBudget(String id);
}

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final SupabaseClient supabaseClient;

  BudgetRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<BudgetModel>> getBudgets() async {
    final userId = supabaseClient.auth.currentUser!.id;
    final response = await supabaseClient
        .from('budgets')
        .select()
        .eq('user_id', userId);
    
    return (response as List).map((json) => BudgetModel.fromJson(json)).toList();
  }

  @override
  Future<void> saveBudget(BudgetModel budget) async {
    await supabaseClient.from('budgets').upsert(budget.toJson());
  }

  @override
  Future<void> deleteBudget(String id) async {
    await supabaseClient.from('budgets').delete().eq('id', id);
  }
}
