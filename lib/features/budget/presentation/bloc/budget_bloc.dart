import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/budget_usecases.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final GetBudgetsUseCase _getBudgetsUseCase;
  final AddBudgetUseCase _addBudgetUseCase;
  final DeleteBudgetUseCase _deleteBudgetUseCase;

  BudgetBloc({
    required GetBudgetsUseCase getBudgetsUseCase,
    required AddBudgetUseCase addBudgetUseCase,
    required DeleteBudgetUseCase deleteBudgetUseCase,
  })  : _getBudgetsUseCase = getBudgetsUseCase,
        _addBudgetUseCase = addBudgetUseCase,
        _deleteBudgetUseCase = deleteBudgetUseCase,
        super(BudgetInitial()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<AddBudget>(_onAddBudget);
    on<DeleteBudget>(_onDeleteBudget);
  }

  Future<void> _onLoadBudgets(LoadBudgets event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    final result = await _getBudgetsUseCase();
    result.fold(
      (failure) => emit(BudgetError(failure)),
      (budgets) => emit(BudgetsLoaded(budgets)),
    );
  }

  Future<void> _onAddBudget(AddBudget event, Emitter<BudgetState> emit) async {
    final result = await _addBudgetUseCase(event.budget);
    result.fold(
      (failure) => emit(BudgetError(failure)),
      (_) => add(LoadBudgets()),
    );
  }

  Future<void> _onDeleteBudget(DeleteBudget event, Emitter<BudgetState> emit) async {
    final result = await _deleteBudgetUseCase(event.id);
    result.fold(
      (failure) => emit(BudgetError(failure)),
      (_) => add(LoadBudgets()),
    );
  }
}
