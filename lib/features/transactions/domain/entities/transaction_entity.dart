import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class TransactionEntity extends Equatable {
  final String id;
  final String walletId;
  final String categoryId;
  final String userId;
  final double amount;
  final TransactionType type;
  final String note;
  final String? receiptUrl;
  final DateTime transactionDate;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.walletId,
    required this.categoryId,
    required this.userId,
    required this.amount,
    required this.type,
    required this.note,
    this.receiptUrl,
    required this.transactionDate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        walletId,
        categoryId,
        userId,
        amount,
        type,
        note,
        receiptUrl,
        transactionDate,
        createdAt,
      ];
}
