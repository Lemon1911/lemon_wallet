import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecase/transaction_usecases.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsUseCase _getTransactionsUseCase;
  final AddTransactionUseCase _addTransactionUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  
  List<CategoryEntity>? _cachedCategories;

  TransactionBloc({
    required GetTransactionsUseCase getTransactionsUseCase,
    required AddTransactionUseCase addTransactionUseCase,
    required GetCategoriesUseCase getCategoriesUseCase,
  })  : _getTransactionsUseCase = getTransactionsUseCase,
        _addTransactionUseCase = addTransactionUseCase,
        _getCategoriesUseCase = getCategoriesUseCase,
        super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadCategories>(_onLoadCategories);
    on<AddTransaction>(_onAddTransaction);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await _getCategoriesUseCase();
    result.fold(
      (failure) => emit(TransactionError(failure)),
      (categories) {
        _cachedCategories = categories;
        emit(CategoriesLoaded(categories));
      },
    );
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    
    if (_cachedCategories == null || _cachedCategories!.isEmpty) {
      final catResult = await _getCategoriesUseCase();
      catResult.fold(
        (_) {}, 
        (categories) => _cachedCategories = categories,
      );
    }
    
    final result = await _getTransactionsUseCase(walletId: event.walletId);
    result.fold(
      (failure) => emit(TransactionError(failure)),
      (transactions) => emit(TransactionsLoaded(transactions, _cachedCategories ?? [])),
    );
  }

  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    final result = await _addTransactionUseCase(
      walletId: event.walletId,
      categoryId: event.categoryId,
      amount: event.amount,
      type: event.type,
      note: event.note,
      transactionDate: event.transactionDate,
    );
    result.fold(
      (failure) => emit(TransactionError(failure)),
      (_) => emit(TransactionSuccess()),
    );
  }
}
