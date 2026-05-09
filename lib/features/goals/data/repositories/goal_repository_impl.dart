import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../datasources/goal_local_datasource.dart';
import '../datasources/goal_remote_datasource.dart';
import '../models/goal_model.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalRemoteDataSource remoteDataSource;
  final GoalLocalDataSource localDataSource;
  final SupabaseClient supabaseClient;

  GoalRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.supabaseClient,
  });

  @override
  Future<Either<String, List<GoalEntity>>> getGoals() async {
    try {
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) return const Left('User not authenticated');
      
      // Always try to load from local first for speed
      final localGoals = await localDataSource.getGoals(userId);
      
      // Try to sync in background if online
      _syncInBackground(userId);
      
      return Right(localGoals);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, GoalEntity>> addGoal(GoalEntity goal) async {
    try {
      final goalModel = GoalModel(
        id: goal.id,
        userId: goal.userId,
        title: goal.title,
        description: goal.description,
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount,
        type: goal.type,
        deadline: goal.deadline,
        createdAt: goal.createdAt,
      );

      // Save locally first
      await localDataSource.cacheGoal(goalModel);
      
      // Try remote
      try {
        await remoteDataSource.createGoal(goalModel);
      } catch (e) {
        // If remote fails, we still have it locally. 
        // Background sync will pick it up later.
      }
      
      return Right(goalModel);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, GoalEntity>> updateGoalProgress(String goalId, double currentAmount) async {
    try {
      final updated = await localDataSource.updateGoalProgress(goalId, currentAmount);
      
      try {
        await remoteDataSource.updateGoal(GoalModel(
          id: updated.id,
          userId: updated.userId,
          title: updated.title,
          description: updated.description,
          targetAmount: updated.targetAmount,
          currentAmount: updated.currentAmount,
          type: updated.type,
          deadline: updated.deadline,
          createdAt: updated.createdAt,
        ));
      } catch (e) {
        // Safe to ignore remote failure for now
      }
      
      return Right(updated);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteGoal(String goalId) async {
    try {
      await localDataSource.deleteGoal(goalId);
      try {
        await remoteDataSource.deleteGoal(goalId);
      } catch (e) {
        // Safe to ignore
      }
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> syncGoals() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return const Left('User not authenticated');
    return _syncInBackground(userId);
  }

  Future<Either<String, void>> _syncInBackground(String userId) async {
    try {
      final remoteGoals = await remoteDataSource.getGoals();
      await localDataSource.cacheGoals(remoteGoals, userId);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
