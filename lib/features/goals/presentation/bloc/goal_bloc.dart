import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/goal_repository.dart';
import 'goal_event.dart';
import 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final GoalRepository repository;

  GoalBloc({required this.repository}) : super(GoalInitial()) {
    on<LoadGoals>(_onLoadGoals);
    on<AddGoal>(_onAddGoal);
    on<UpdateGoalProgress>(_onUpdateGoalProgress);
    on<DeleteGoal>(_onDeleteGoal);
    on<SyncGoals>(_onSyncGoals);
  }

  Future<void> _onLoadGoals(LoadGoals event, Emitter<GoalState> emit) async {
    emit(GoalLoading());
    final result = await repository.getGoals();
    result.fold(
      (failure) => emit(GoalError(failure.toString())),
      (goals) => emit(GoalLoaded(goals)),
    );
  }

  Future<void> _onAddGoal(AddGoal event, Emitter<GoalState> emit) async {
    final result = await repository.addGoal(event.goal);
    result.fold(
      (failure) => emit(GoalError(failure.toString())),
      (_) {
        emit(const GoalOperationSuccess('Goal created successfully!'));
        add(LoadGoals());
      },
    );
  }

  Future<void> _onUpdateGoalProgress(UpdateGoalProgress event, Emitter<GoalState> emit) async {
    final result = await repository.updateGoalProgress(event.goalId, event.currentAmount);
    result.fold(
      (failure) => emit(GoalError(failure.toString())),
      (_) => add(LoadGoals()),
    );
  }

  Future<void> _onDeleteGoal(DeleteGoal event, Emitter<GoalState> emit) async {
    final result = await repository.deleteGoal(event.goalId);
    result.fold(
      (failure) => emit(GoalError(failure.toString())),
      (_) {
        emit(const GoalOperationSuccess('Goal deleted!'));
        add(LoadGoals());
      },
    );
  }

  Future<void> _onSyncGoals(SyncGoals event, Emitter<GoalState> emit) async {
    await repository.syncGoals();
    add(LoadGoals());
  }
}
