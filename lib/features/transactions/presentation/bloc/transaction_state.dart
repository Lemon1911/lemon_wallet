import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionsLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  const TransactionsLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class CategoriesLoaded extends TransactionState {
  final List<CategoryEntity> categories;
  const CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class TransactionSuccess extends TransactionState {}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
