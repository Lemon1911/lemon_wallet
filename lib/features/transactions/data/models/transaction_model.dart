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
      id: (json['id'] ?? '').toString(),
      walletId: (json['wallet_id'] ?? '').toString(),
      categoryId: (json['category_id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      note: json['note']?.toString() ?? '',
      receiptUrl: json['receipt_url']?.toString(),
      transactionDate: json['transaction_date'] != null 
          ? DateTime.parse(json['transaction_date'].toString())
          : DateTime.now(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'category_id': categoryId,
      'user_id': userId,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'note': note,
      'receipt_url': receiptUrl,
      'transaction_date': transactionDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
