import 'package:equatable/equatable.dart';

class BudgetEntity extends Equatable {
  final String id;
  final String userId;
  final String categoryId;
  final double amountLimit;
  final String period; // e.g., 'monthly'
  final DateTime startDate;

  const BudgetEntity({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amountLimit,
    required this.period,
    required this.startDate,
  });

  @override
  List<Object?> get props => [id, userId, categoryId, amountLimit, period, startDate];
}
