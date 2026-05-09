import 'package:dartz/dartz.dart';
import '../entities/transaction_entity.dart';
import '../entities/category_entity.dart';
import '../repo/transaction_repository.dart';

class AddTransactionUseCase {
  final TransactionRepository repository;

  AddTransactionUseCase(this.repository);

  Future<Either<String, TransactionEntity>> call({
    required String walletId,
    required String categoryId,
    required double amount,
    required TransactionType type,
    required String note,
    required DateTime transactionDate,
    String? receiptUrl,
  }) {
    return repository.addTransaction(
      walletId: walletId,
      categoryId: categoryId,
      amount: amount,
      type: type,
      note: note,
      transactionDate: transactionDate,
      receiptUrl: receiptUrl,
    );
  }
}

class GetTransactionsUseCase {
  final TransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<Either<String, List<TransactionEntity>>> call({
    required String walletId,
  }) {
    return repository.getTransactions(walletId: walletId);
  }
}

class GetCategoriesUseCase {
  final TransactionRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<Either<String, List<CategoryEntity>>> call() {
    return repository.getCategories();
  }
}

class WatchTransactionsUseCase {
  final TransactionRepository repository;

  WatchTransactionsUseCase(this.repository);

  Stream<List<TransactionEntity>> call({required String walletId}) {
    return repository.watchTransactions(walletId: walletId);
  }
}
