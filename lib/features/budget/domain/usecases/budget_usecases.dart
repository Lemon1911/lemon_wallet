import 'package:dartz/dartz.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

class GetBudgetsUseCase {
  final BudgetRepository repository;
  GetBudgetsUseCase(this.repository);

  Future<Either<String, List<BudgetEntity>>> call() {
    return repository.getBudgets();
  }
}

class AddBudgetUseCase {
  final BudgetRepository repository;
  AddBudgetUseCase(this.repository);

  Future<Either<String, void>> call(BudgetEntity budget) {
    return repository.addBudget(budget);
  }
}

class DeleteBudgetUseCase {
  final BudgetRepository repository;
  DeleteBudgetUseCase(this.repository);

  Future<Either<String, void>> call(String id) {
    return repository.deleteBudget(id);
  }
}
