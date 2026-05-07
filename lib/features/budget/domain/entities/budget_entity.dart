import 'package:equatable/equatable.dart';

class BudgetEntity extends Equatable {
  final String id;
  final String categoryId;
  final double amountLimit;
  final String period; // e.g., 'monthly'
  final DateTime startDate;

  const BudgetEntity({
    required this.id,
    required this.categoryId,
    required this.amountLimit,
    required this.period,
    required this.startDate,
  });

  @override
  List<Object?> get props => [id, categoryId, amountLimit, period, startDate];
}
