import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecase/transaction_usecases.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsUseCase _getTransactionsUseCase;
  final AddTransactionUseCase _addTransactionUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final WatchTransactionsUseCase _watchTransactionsUseCase;
  
  StreamSubscription? _transactionSubscription;
  
  List<CategoryEntity>? _cachedCategories;
  List<TransactionEntity> _allTransactions = [];

  TransactionBloc({
    required GetTransactionsUseCase getTransactionsUseCase,
    required AddTransactionUseCase addTransactionUseCase,
    required GetCategoriesUseCase getCategoriesUseCase,
    required WatchTransactionsUseCase watchTransactionsUseCase,
  })  : _getTransactionsUseCase = getTransactionsUseCase,
        _addTransactionUseCase = addTransactionUseCase,
        _getCategoriesUseCase = getCategoriesUseCase,
        _watchTransactionsUseCase = watchTransactionsUseCase,
        super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<WatchTransactions>(_onWatchTransactions);
    on<TransactionsUpdated>(_onTransactionsUpdated);
    on<LoadCategories>(_onLoadCategories);
    on<AddTransaction>(_onAddTransaction);
    on<FilterTransactions>(_onFilterTransactions);
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    return super.close();
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
      (transactions) {
        _allTransactions = transactions;
        emit(TransactionsLoaded(transactions, _cachedCategories ?? []));
      },
    );
  }

  Future<void> _onWatchTransactions(WatchTransactions event, Emitter<TransactionState> emit) async {
    _transactionSubscription?.cancel();
    _transactionSubscription = _watchTransactionsUseCase(walletId: event.walletId).listen((transactions) {
      add(TransactionsUpdated(transactions));
    });
  }

  void _onTransactionsUpdated(TransactionsUpdated event, Emitter<TransactionState> emit) {
    _allTransactions = event.transactions;
    emit(TransactionsLoaded(event.transactions, _cachedCategories ?? []));
  }

  void _onFilterTransactions(FilterTransactions event, Emitter<TransactionState> emit) {
    if (state is! TransactionsLoaded && state is! TransactionInitial) return;

    List<TransactionEntity> filtered = _allTransactions;

    if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
      final query = event.searchQuery!.toLowerCase();
      filtered = filtered.where((tx) => 
        tx.note.toLowerCase().contains(query)
      ).toList();
    }

    if (event.categoryId != null) {
      filtered = filtered.where((tx) => tx.categoryId == event.categoryId).toList();
    }

    if (event.startDate != null) {
      filtered = filtered.where((tx) => tx.transactionDate.isAfter(event.startDate!)).toList();
    }

    if (event.endDate != null) {
      filtered = filtered.where((tx) => tx.transactionDate.isBefore(event.endDate!)).toList();
    }

    emit(TransactionsLoaded(filtered, _cachedCategories ?? []));
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
      (transaction) {
        // Update local list for immediate UI response
        _allTransactions.insert(0, transaction);
        emit(TransactionSuccess());
        // Emit loaded state so listeners update their UI
        emit(TransactionsLoaded(_allTransactions, _cachedCategories ?? []));
      },
    );
  }
}
