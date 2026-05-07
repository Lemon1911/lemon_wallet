import 'package:sqflite/sqflite.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../../../../core/database/database_helper.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getTransactions(String walletId);
  Future<void> cacheTransactions(List<TransactionModel> transactions);
  Future<void> saveTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  
  Future<List<CategoryModel>> getCategories();
  Future<void> cacheCategories(List<CategoryModel> categories);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final DatabaseHelper databaseHelper;

  TransactionLocalDataSourceImpl(this.databaseHelper);

  @override
  Future<List<TransactionModel>> getTransactions(String walletId) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'wallet_id = ?',
      whereArgs: [walletId],
      orderBy: 'transaction_date DESC',
    );
    return maps.map((map) => TransactionModel.fromJson(map)).toList();
  }

  @override
  Future<void> cacheTransactions(List<TransactionModel> transactions) async {
    final db = await databaseHelper.database;
    final batch = db.batch();
    for (var tx in transactions) {
      batch.insert('transactions', tx.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> saveTransaction(TransactionModel transaction) async {
    final db = await databaseHelper.database;
    await db.insert('transactions', transaction.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final db = await databaseHelper.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return maps.map((map) => CategoryModel.fromJson(map)).toList();
  }

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    final db = await databaseHelper.database;
    final batch = db.batch();
    for (var cat in categories) {
      batch.insert('categories', cat.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}
