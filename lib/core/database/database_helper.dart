import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lemon_wallet.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Wallets Table
    await db.execute('''
      CREATE TABLE wallets (
        id TEXT PRIMARY KEY,
        name TEXT,
        balance REAL,
        currency TEXT,
        user_id TEXT,
        created_at TEXT
      )
    ''');

    // Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT,
        type TEXT,
        icon TEXT
      )
    ''');

    // Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        wallet_id TEXT,
        category_id TEXT,
        amount REAL,
        type TEXT,
        note TEXT,
        transaction_date TEXT,
        receipt_url TEXT,
        FOREIGN KEY (wallet_id) REFERENCES wallets (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('categories');
    await db.delete('wallets');
  }
}
