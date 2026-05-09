import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/csv_helper.dart';
import '../../../../core/utils/icon_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_components.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    context.read<TransactionBloc>().add(FilterTransactions(
          searchQuery: _searchController.text,
          categoryId: _selectedCategoryId,
        ));
  }

  Future<void> _importCsv(BuildContext context) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final transactionsData = await CsvHelper.importTransactionsFromCsv(file);
      
      if (!context.mounted) return;

      if (transactionsData.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported ${transactionsData.length} entries. Processing...')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, walletState) {
        if (walletState is WalletsLoaded && walletState.wallets.isNotEmpty) {
          // Only load if not already loaded or if wallet changed
          // For simplicity, we load here, but typically you'd trigger this elsewhere
          // context.read<TransactionBloc>().add(LoadTransactions(walletId));
          
          return BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state is TransactionLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is TransactionsLoaded) {
                return _buildTransactionList(state.transactions, state.categories);
              }
              return const Center(child: Text('Load transactions...'));
            },
          );
        }
        return const Center(child: Text('No wallets found'));
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_rounded, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text('No transactions found', style: TextStyle(color: AppColors.textSecondaryDark)),
          if (_searchController.text.isNotEmpty || _selectedCategoryId != null)
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _selectedCategoryId = null);
                _onFilterChanged();
              },
              child: const Text('Clear Filters', style: TextStyle(color: AppColors.primary)),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<TransactionEntity> transactions, List<CategoryEntity> categories) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(transactions),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildFilterChips(categories),
              const SizedBox(height: 24),
              if (transactions.isEmpty)
                _buildEmptyState()
              else
                ...transactions.map((tx) {
                  final category = categories.cast<CategoryEntity>().firstWhere(
                    (c) => c.id == tx.categoryId,
                    orElse: () => const CategoryEntity(id: '', name: 'Transaction', type: '', icon: 'default'),
                  );
                  return _buildTransactionItem(
                    icon: IconHelper.getIconData(category.icon, category.name),
                    title: tx.note.isEmpty ? category.name : tx.note,
                    time: '${tx.transactionDate.day}/${tx.transactionDate.month}',
                    amount: '${tx.type == TransactionType.income ? '+' : '-'} \$${tx.amount.toStringAsFixed(2)}',
                    isPositive: tx.type == TransactionType.income,
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(List<TransactionEntity> transactions) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Transactions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.file_upload_rounded, color: AppColors.primary),
              onPressed: () => _importCsv(context),
            ),
            IconButton(
              icon: const Icon(Icons.ios_share_rounded, color: AppColors.primary),
              onPressed: () => CsvHelper.exportTransactionsToCsv(transactions),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildSearchBar() {
    return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          borderRadius: BorderRadius.circular(50),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => _onFilterChanged(),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              hintStyle: const TextStyle(color: AppColors.textSecondaryDark),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondaryDark,
              ),
              suffixIcon: _searchController.text.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondaryDark, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      _onFilterChanged();
                    },
                  )
                : null,
              border: InputBorder.none,
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildFilterChips(List<CategoryEntity> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All'),
              selected: _selectedCategoryId == null,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategoryId = null);
                  _onFilterChanged();
                }
              },
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: _selectedCategoryId == null ? AppColors.backgroundDark : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...categories.map((category) {
            final isSelected = _selectedCategoryId == category.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedCategoryId = selected ? category.id : null);
                  _onFilterChanged();
                },
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.backgroundDark : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String time,
    required String amount,
    bool isPositive = false,
  }) {
    return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            hasBlur: false,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.accent, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          color: AppColors.textSecondaryDark,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    color: isPositive ? AppColors.primary : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideY(begin: 0.1, end: 0);
  }
}
