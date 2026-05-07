import 'package:dartz/dartz.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repo/transaction_repository.dart';
import '../datasource/transaction_remote_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<String, List<TransactionEntity>>> getTransactions({
    required String walletId,
  }) async {
    try {
      final transactions = await remoteDataSource.getTransactions(walletId: walletId);
      return Right(transactions);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, TransactionEntity>> addTransaction({
    required String walletId,
    required String categoryId,
    required double amount,
    required TransactionType type,
    required String note,
    required DateTime transactionDate,
    String? receiptUrl,
  }) async {
    try {
      final transaction = await remoteDataSource.addTransaction(
        walletId: walletId,
        categoryId: categoryId,
        amount: amount,
        type: type,
        note: note,
        transactionDate: transactionDate,
        receiptUrl: receiptUrl,
      );
      return Right(transaction);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteTransaction(String transactionId) async {
    try {
      await remoteDataSource.deleteTransaction(transactionId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
