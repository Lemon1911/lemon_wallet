import 'package:dartz/dartz.dart';
import '../entities/goal_entity.dart';

abstract class GoalRepository {
  Future<Either<String, List<GoalEntity>>> getGoals();
  Future<Either<String, GoalEntity>> addGoal(GoalEntity goal);
  Future<Either<String, GoalEntity>> updateGoalProgress(String goalId, double currentAmount);
  Future<Either<String, void>> deleteGoal(String goalId);
  Future<Either<String, void>> syncGoals();
}
