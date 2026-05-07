import 'package:dartz/dartz.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repo/transaction_repository.dart';
import '../datasource/transaction_remote_datasource.dart';

import '../datasource/transaction_local_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<String, List<TransactionEntity>>> getTransactions({
    required String walletId,
  }) async {
    try {
      final transactions = await remoteDataSource.getTransactions(walletId: walletId);
      await localDataSource.cacheTransactions(transactions);
      return Right(transactions);
    } catch (e) {
      final localTransactions = await localDataSource.getTransactions(walletId);
      if (localTransactions.isNotEmpty) {
        return Right(localTransactions);
      }
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      await localDataSource.cacheCategories(categories);
      return Right(categories);
    } catch (e) {
      final localCategories = await localDataSource.getCategories();
      if (localCategories.isNotEmpty) {
        return Right(localCategories);
      }
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
      await localDataSource.saveTransaction(transaction);
      return Right(transaction);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteTransaction(String transactionId) async {
    try {
      await remoteDataSource.deleteTransaction(transactionId);
      await localDataSource.deleteTransaction(transactionId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
