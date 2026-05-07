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

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, walletState) {
        if (walletState is WalletsLoaded && walletState.wallets.isNotEmpty) {
          final walletId = walletState.wallets.first.id;
          context.read<TransactionBloc>().add(LoadTransactions(walletId));
          
          return BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state is TransactionLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is TransactionsLoaded) {
                if (state.transactions.isEmpty) {
                  return _buildEmptyState();
                }
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
          Text('No transactions yet', style: TextStyle(color: AppColors.textSecondaryDark)),
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
              const SizedBox(height: 32),
              ...transactions.map((tx) {
                final category = categories.firstWhere(
                  (c) => c.id == tx.categoryId,
                  orElse: () => const CategoryEntity(id: '', name: 'Transaction', type: '', icon: 'default'),
                );
                return _buildTransactionItem(
                  icon: IconHelper.getIconData(category.icon),
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

  // Icon mapping moved to IconHelper


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
              icon: const Icon(Icons.ios_share_rounded, color: AppColors.primary),
              onPressed: () => CsvHelper.exportTransactionsToCsv(transactions),
            ),
            const SizedBox(width: 8),
            GlassCard(
              padding: const EdgeInsets.all(10),
              borderRadius: BorderRadius.circular(12),
              child: const Icon(
                Icons.filter_list_rounded,
                color: Colors.white,
                size: 20,
              ),
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
          child: const TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              hintStyle: TextStyle(color: AppColors.textSecondaryDark),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.textSecondaryDark,
              ),
              border: InputBorder.none,
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .scale(begin: const Offset(0.95, 0.95));
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
            hasBlur: false, // Performance optimization for lists
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
                        style: TextStyle(
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
