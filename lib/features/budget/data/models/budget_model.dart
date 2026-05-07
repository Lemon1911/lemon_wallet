import '../../domain/entities/budget_entity.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.categoryId,
    required super.amountLimit,
    required super.period,
    required super.startDate,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      categoryId: json['category_id'],
      amountLimit: (json['amount_limit'] as num).toDouble(),
      period: json['period'],
      startDate: DateTime.parse(json['start_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount_limit': amountLimit,
      'period': period,
      'start_date': startDate.toIso8601String(),
    };
  }
}
