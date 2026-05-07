import 'package:dartz/dartz.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;

  BudgetRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<String, List<BudgetEntity>>> getBudgets() async {
    try {
      final budgets = await localDataSource.getBudgets();
      return Right(budgets);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> addBudget(BudgetEntity budget) async {
    try {
      final model = BudgetModel(
        id: budget.id,
        categoryId: budget.categoryId,
        amountLimit: budget.amountLimit,
        period: budget.period,
        startDate: budget.startDate,
      );
      await localDataSource.saveBudget(model);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteBudget(String id) async {
    try {
      await localDataSource.deleteBudget(id);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
