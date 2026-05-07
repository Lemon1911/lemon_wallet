import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  final String walletId;
  const LoadTransactions(this.walletId);

  @override
  List<Object?> get props => [walletId];
}

class LoadCategories extends TransactionEvent {}

class AddTransaction extends TransactionEvent {
  final String walletId;
  final String categoryId;
  final double amount;
  final TransactionType type;
  final String note;
  final DateTime transactionDate;

  const AddTransaction({
    required this.walletId,
    required this.categoryId,
    required this.amount,
    required this.type,
    required this.note,
    required this.transactionDate,
  });

  @override
  List<Object?> get props => [walletId, categoryId, amount, type, note, transactionDate];
}

class FilterTransactions extends TransactionEvent {
  final String? searchQuery;
  final String? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterTransactions({
    this.searchQuery,
    this.categoryId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [searchQuery, categoryId, startDate, endDate];
}
