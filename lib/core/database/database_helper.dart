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
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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

    // Categories Table — matches Supabase schema
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT,
        icon TEXT,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        wallet_id TEXT,
        category_id TEXT,
        user_id TEXT,
        amount REAL,
        type TEXT,
        note TEXT,
        transaction_date TEXT,
        receipt_url TEXT,
        created_at TEXT,
        FOREIGN KEY (wallet_id) REFERENCES wallets (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Budgets Table — includes created_at to match Supabase
    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        category_id TEXT,
        amount_limit REAL,
        period TEXT DEFAULT 'monthly',
        start_date TEXT,
        created_at TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Goals Table — mirrors the Supabase goals table
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL DEFAULT 0.0,
        type TEXT NOT NULL,
        deadline TEXT,
        created_at TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // v1 → v2: add user_id + created_at to transactions
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE transactions ADD COLUMN user_id TEXT');
      await db.execute('ALTER TABLE transactions ADD COLUMN created_at TEXT');
    }

    // v2 → v3: add is_default to categories, created_at to budgets, create goals table
    if (oldVersion < 3) {
      // Safely add is_default column to categories
      try {
        await db.execute('ALTER TABLE categories ADD COLUMN is_default INTEGER NOT NULL DEFAULT 0');
      } catch (_) {
        // Column might already exist on a fresh install — safe to ignore
      }

      // Safely add created_at to budgets
      try {
        await db.execute('ALTER TABLE budgets ADD COLUMN created_at TEXT');
      } catch (_) {}

      // Create goals table if it doesn't exist
      await db.execute('''
        CREATE TABLE IF NOT EXISTS goals (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          target_amount REAL NOT NULL,
          current_amount REAL NOT NULL DEFAULT 0.0,
          type TEXT NOT NULL,
          deadline TEXT,
          created_at TEXT
        )
      ''');
    }
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('categories');
    await db.delete('wallets');
    await db.delete('budgets');
    await db.delete('goals');
  }
}
