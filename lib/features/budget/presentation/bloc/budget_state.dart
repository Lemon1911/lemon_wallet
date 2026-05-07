import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_entity.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();
  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {}
class BudgetLoading extends BudgetState {}
class BudgetsLoaded extends BudgetState {
  final List<BudgetEntity> budgets;
  const BudgetsLoaded(this.budgets);
  @override
  List<Object?> get props => [budgets];
}
class BudgetError extends BudgetState {
  final String message;
  const BudgetError(this.message);
  @override
  List<Object?> get props => [message];
}
