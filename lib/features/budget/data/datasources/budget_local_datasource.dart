import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/budget_model.dart';

abstract class BudgetLocalDataSource {
  Future<void> cacheBudgets(List<BudgetModel> budgets, String userId);
  Future<List<BudgetModel>> getBudgets(String userId);
  Future<void> saveBudget(BudgetModel budget);
  Future<void> deleteBudget(String id);
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  final DatabaseHelper _dbHelper;

  BudgetLocalDataSourceImpl(this._dbHelper);

  @override
  Future<void> cacheBudgets(List<BudgetModel> budgets, String userId) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    batch.delete('budgets', where: 'user_id = ?', whereArgs: [userId]);
    for (var budget in budgets) {
      batch.insert('budgets', budget.toJson());
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<List<BudgetModel>> getBudgets(String userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => BudgetModel.fromJson(map)).toList();
  }

  @override
  Future<void> saveBudget(BudgetModel budget) async {
    final db = await _dbHelper.database;
    await db.insert(
      'budgets',
      budget.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteBudget(String id) async {
    final db = await _dbHelper.database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }
}
