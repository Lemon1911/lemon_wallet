import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';
import '../datasources/budget_remote_datasource.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;
  final BudgetRemoteDataSource remoteDataSource;
  final SupabaseClient supabaseClient;

  BudgetRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.supabaseClient,
  });

  String get _currentUserId => supabaseClient.auth.currentUser?.id ?? '';

  @override
  Future<Either<String, List<BudgetEntity>>> getBudgets() async {
    final userId = _currentUserId;
    if (userId.isEmpty) return const Left('User not authenticated');

    try {
      // Try to sync from remote
      try {
        final remoteBudgets = await remoteDataSource.getBudgets();
        await localDataSource.cacheBudgets(remoteBudgets, userId);
      } catch (remoteError) {
        // Remote fetch failed
      }

      final budgets = await localDataSource.getBudgets(userId);
      return Right(budgets);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> addBudget(BudgetEntity budget) async {
    final userId = _currentUserId;
    if (userId.isEmpty) return const Left('User not authenticated');

    final model = BudgetModel(
      id: budget.id,
      userId: userId,
      categoryId: budget.categoryId,
      amountLimit: budget.amountLimit,
      period: budget.period,
      startDate: budget.startDate,
    );

    try {
      await localDataSource.saveBudget(model);
      
      try {
        await remoteDataSource.saveBudget(model);
      } catch (remoteError) {
        // Remote save failed
      }
      
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteBudget(String id) async {
    try {
      await localDataSource.deleteBudget(id);
      
      try {
        await remoteDataSource.deleteBudget(id);
      } catch (remoteError) {
        // Remote delete failed
      }
      
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
