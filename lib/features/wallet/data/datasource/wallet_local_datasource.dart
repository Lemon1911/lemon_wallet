import 'package:sqflite/sqflite.dart';
import '../models/wallet_model.dart';
import '../../../../core/database/database_helper.dart';

abstract class WalletLocalDataSource {
  Future<List<WalletModel>> getWallets();
  Future<void> cacheWallets(List<WalletModel> wallets);
  Future<void> saveWallet(WalletModel wallet);
  Future<void> deleteWallet(String id);
}

class WalletLocalDataSourceImpl implements WalletLocalDataSource {
  final DatabaseHelper databaseHelper;

  WalletLocalDataSourceImpl(this.databaseHelper);

  @override
  Future<List<WalletModel>> getWallets() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('wallets');
    return maps.map((map) => WalletModel.fromJson(map)).toList();
  }

  @override
  Future<void> cacheWallets(List<WalletModel> wallets) async {
    final db = await databaseHelper.database;
    final batch = db.batch();
    // Clear old wallets? Or just upsert?
    // For simplicity, we'll upsert (replace)
    for (var wallet in wallets) {
      batch.insert('wallets', wallet.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> saveWallet(WalletModel wallet) async {
    final db = await databaseHelper.database;
    await db.insert('wallets', wallet.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> deleteWallet(String id) async {
    final db = await databaseHelper.database;
    await db.delete('wallets', where: 'id = ?', whereArgs: [id]);
  }
}
