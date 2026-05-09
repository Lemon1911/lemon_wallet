import 'package:equatable/equatable.dart';
import '../../domain/entities/goal_entity.dart';

abstract class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object?> get props => [];
}

class LoadGoals extends GoalEvent {}

class AddGoal extends GoalEvent {
  final GoalEntity goal;
  const AddGoal(this.goal);

  @override
  List<Object?> get props => [goal];
}

class UpdateGoalProgress extends GoalEvent {
  final String goalId;
  final double currentAmount;
  const UpdateGoalProgress(this.goalId, this.currentAmount);

  @override
  List<Object?> get props => [goalId, currentAmount];
}

class DeleteGoal extends GoalEvent {
  final String goalId;
  const DeleteGoal(this.goalId);

  @override
  List<Object?> get props => [goalId];
}

class SyncGoals extends GoalEvent {}
