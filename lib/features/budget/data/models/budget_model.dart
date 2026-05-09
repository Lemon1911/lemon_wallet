import '../../domain/entities/budget_entity.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.userId,
    required super.categoryId,
    required super.amountLimit,
    required super.period,
    required super.startDate,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      categoryId: (json['category_id'] ?? '').toString(),
      // Handle both numeric (Supabase) and null edge cases safely
      amountLimit: double.tryParse(json['amount_limit']?.toString() ?? '0') ?? 0.0,
      period: (json['period'] ?? 'monthly').toString(),
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'amount_limit': amountLimit,
      'period': period,
      'start_date': startDate.toIso8601String(),
    };
  }
}
