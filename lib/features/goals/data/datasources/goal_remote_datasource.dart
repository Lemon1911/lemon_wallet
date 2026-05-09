import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/goal_model.dart';

abstract class GoalRemoteDataSource {
  Future<List<GoalModel>> getGoals();
  Future<GoalModel> saveGoal(GoalModel goal);
  Future<void> updateGoalProgress(String goalId, double currentAmount);
  Future<void> deleteGoal(String goalId);
}

class GoalRemoteDataSourceImpl implements GoalRemoteDataSource {
  final SupabaseClient supabaseClient;

  GoalRemoteDataSourceImpl(this.supabaseClient);

  String get _userId => supabaseClient.auth.currentUser?.id ?? '';

  @override
  Future<List<GoalModel>> getGoals() async {
    final response = await supabaseClient
        .from('goals')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => GoalModel.fromJson(json)).toList();
  }

  @override
  Future<GoalModel> saveGoal(GoalModel goal) async {
    final response = await supabaseClient
        .from('goals')
        .upsert(goal.toJson())
        .select()
        .single();

    return GoalModel.fromJson(response);
  }

  @override
  Future<void> updateGoalProgress(String goalId, double currentAmount) async {
    await supabaseClient
        .from('goals')
        .update({'current_amount': currentAmount}).eq('id', goalId);
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    await supabaseClient.from('goals').delete().eq('id', goalId);
  }
}
