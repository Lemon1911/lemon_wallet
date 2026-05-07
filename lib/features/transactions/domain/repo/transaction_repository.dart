import 'package:dartz/dartz.dart';
import '../entities/transaction_entity.dart';
import '../entities/category_entity.dart';

abstract class TransactionRepository {
  Future<Either<String, List<TransactionEntity>>> getTransactions({
    required String walletId,
  });

  Future<Either<String, List<CategoryEntity>>> getCategories();

  Future<Either<String, TransactionEntity>> addTransaction({
    required String walletId,
    required String categoryId,
    required double amount,
    required TransactionType type,
    required String note,
    required DateTime transactionDate,
    String? receiptUrl,
  });

  Future<Either<String, void>> deleteTransaction(String transactionId);
}
