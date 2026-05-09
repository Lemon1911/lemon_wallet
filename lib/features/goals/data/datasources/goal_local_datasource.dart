import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/goal_model.dart';

abstract class GoalLocalDataSource {
  Future<List<GoalModel>> getGoals(String userId);
  Future<void> cacheGoals(List<GoalModel> goals, String userId);
  Future<void> cacheGoal(GoalModel goal);
  Future<GoalModel> updateGoalProgress(String goalId, double currentAmount);
  Future<void> deleteGoal(String goalId);
}

class GoalLocalDataSourceImpl implements GoalLocalDataSource {
  final DatabaseHelper _dbHelper;

  GoalLocalDataSourceImpl(this._dbHelper);

  @override
  Future<List<GoalModel>> getGoals(String userId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'goals',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => GoalModel.fromJson(map)).toList();
  }

  @override
  Future<void> cacheGoals(List<GoalModel> goals, String userId) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    // Clear old goals for this user before re-caching
    batch.delete('goals', where: 'user_id = ?', whereArgs: [userId]);
    for (final goal in goals) {
      batch.insert('goals', goal.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> cacheGoal(GoalModel goal) async {
    final db = await _dbHelper.database;
    await db.insert('goals', goal.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<GoalModel> updateGoalProgress(String goalId, double currentAmount) async {
    final db = await _dbHelper.database;
    await db.update(
      'goals',
      {'current_amount': currentAmount},
      where: 'id = ?',
      whereArgs: [goalId],
    );
    final maps = await db.query('goals', where: 'id = ?', whereArgs: [goalId]);
    return GoalModel.fromJson(maps.first);
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    final db = await _dbHelper.database;
    await db.delete('goals', where: 'id = ?', whereArgs: [goalId]);
  }
}
