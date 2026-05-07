import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.walletId,
    required super.categoryId,
    required super.userId,
    required super.amount,
    required super.type,
    required super.note,
    super.receiptUrl,
    required super.transactionDate,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      walletId: json['wallet_id'] as String,
      categoryId: json['category_id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      note: json['note'] ?? '',
      receiptUrl: json['receipt_url'] as String?,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wallet_id': walletId,
      'category_id': categoryId,
      'user_id': userId,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'note': note,
      'receipt_url': receiptUrl,
      'transaction_date': transactionDate.toIso8601String(),
    };
  }
}
