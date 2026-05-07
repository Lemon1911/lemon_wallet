import 'package:dartz/dartz.dart';
import '../entities/budget_entity.dart';

abstract class BudgetRepository {
  Future<Either<String, List<BudgetEntity>>> getBudgets();
  Future<Either<String, void>> addBudget(BudgetEntity budget);
  Future<Either<String, void>> deleteBudget(String id);
}
