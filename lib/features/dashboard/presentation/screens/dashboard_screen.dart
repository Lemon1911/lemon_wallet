import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/icon_helper.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_components.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_event.dart';
import '../../../transactions/presentation/bloc/transaction_state.dart';
import '../../../transactions/domain/entities/category_entity.dart';
import '../../../budget/presentation/bloc/budget_bloc.dart';
import '../../../budget/presentation/bloc/budget_state.dart';
import '../../../budget/presentation/bloc/budget_event.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/di/service_locator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedWalletIndex = 0;
  String? _loadedWalletId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is WalletsLoaded && state.wallets.isNotEmpty) {
          // Ensure index is within bounds if wallets were deleted
          if (_selectedWalletIndex >= state.wallets.length) {
            _selectedWalletIndex = 0;
          }
          
          final walletId = state.wallets[_selectedWalletIndex].id;
          if (_loadedWalletId != walletId) {
            _loadedWalletId = walletId;
            context.read<TransactionBloc>().add(LoadTransactions(walletId));
            context.read<BudgetBloc>().add(LoadBudgets());
          }
        }
      },
      builder: (context, state) {
        if (state is WalletLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WalletsLoaded && state.wallets.isEmpty) {
          return _buildEmptyState(context);
        }

        return BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, txState) {
            List<TransactionEntity> transactions = [];
            List<CategoryEntity> categories = [];
            
            if (txState is TransactionsLoaded) {
              transactions = txState.transactions;
              categories = txState.categories;
            }
            
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<WalletBloc>().add(LoadWallets());
                    if (_loadedWalletId != null) {
                      context.read<TransactionBloc>().add(LoadTransactions(_loadedWalletId!));
                    }
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 32),
                        if (state is WalletsLoaded)
                          _buildBalanceSection(transactions, state.wallets),
                        const SizedBox(height: 32),
                        _buildQuickActions(context, state is WalletsLoaded ? state.wallets : []),
                        const SizedBox(height: 32),
                        _buildSpendingChart(transactions),
                        const SizedBox(height: 32),
                        _buildBudgetSummary(context, transactions, categories),
                        const SizedBox(height: 32),
                        _buildRecentActivity(transactions, categories),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Icon(Icons.account_balance_wallet_rounded, 
                size: 64, color: AppColors.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Wallets Found',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first wallet to start tracking your money with LemonWallet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.push(AppRouter.createWallet),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Create Wallet', style: TextStyle(color: AppColors.backgroundDark, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String name = 'Lemon';
        if (state is AuthAuthenticated) {
          name = state.user.fullName?.split(' ').first ?? 'Lemon';
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello,',
                  style: TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$name!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                // Navigate to profile tab
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/logo_cyan.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildBalanceSection(List<TransactionEntity> transactions, List<WalletEntity> wallets) {
    if (wallets.isEmpty) return const SizedBox.shrink();
    final selectedWallet = wallets[_selectedWalletIndex];
    double totalBalance = 0;
    for (var tx in transactions) {
      if (tx.type == TransactionType.income) {
        totalBalance += tx.amount;
      } else {
        totalBalance -= tx.amount;
      }
    }

    final balanceString = totalBalance.toStringAsFixed(2);
    final isLargeNumber = balanceString.length > 8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showWalletPicker(context, wallets),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedWallet.name.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sl<CurrencyService>().getSymbol(selectedWallet.currency),
              style: TextStyle(
                color: AppColors.primary.withValues(alpha: 0.7),
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                balanceString,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: isLargeNumber ? 32 : 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    )
    .animate()
    .fadeIn(delay: 200.ms, duration: 600.ms)
    .slideX(begin: -0.1, end: 0);
  }

  void _showWalletPicker(BuildContext context, List<WalletEntity> wallets) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Switch Wallet',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: wallets.length,
                  itemBuilder: (context, index) {
                    final wallet = wallets[index];
                    final isSelected = _selectedWalletIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedWalletIndex = index;
                            _loadedWalletId = wallet.id;
                          });
                          context.read<TransactionBloc>().add(LoadTransactions(wallet.id));
                          Navigator.pop(context);
                        },
                        child: GlassCard(
                          border: isSelected ? Border.all(color: AppColors.primary) : null,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  index % 2 == 0 ? Icons.credit_card : Icons.account_balance,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      wallet.name,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      wallet.currency,
                                      style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                text: 'Create New Wallet',
                onPressed: () {
                  Navigator.pop(context);
                  context.push(AppRouter.createWallet);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, List<WalletEntity> wallets) {
    final currentWalletId = wallets.isNotEmpty ? wallets[_selectedWalletIndex].id : null;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ActionPill(icon: Icons.send_rounded, label: 'Send'),
          const SizedBox(width: 16),
          _ActionPill(
            icon: Icons.add_rounded, 
            label: 'Income',
            onTap: () async {
              if (currentWalletId != null) {
                await context.push(AppRouter.addTransaction, extra: {
                  'walletId': currentWalletId,
                  'type': TransactionType.income,
                });
                // Refresh wallet balance and budgets after adding transaction
                if (context.mounted) {
                  context.read<WalletBloc>().add(LoadWallets());
                  context.read<BudgetBloc>().add(LoadBudgets());
                }
              }
            },
          ),
          const SizedBox(width: 16),
          _ActionPill(
            icon: Icons.payment_rounded, 
            label: 'Pay',
            onTap: () async {
              if (currentWalletId != null) {
                await context.push(AppRouter.addTransaction, extra: {
                  'walletId': currentWalletId,
                  'type': TransactionType.expense,
                });
                // Refresh wallet balance and budgets after adding transaction
                if (context.mounted) {
                  context.read<WalletBloc>().add(LoadWallets());
                  context.read<BudgetBloc>().add(LoadBudgets());
                }
              }
            },
          ),
          const SizedBox(width: 16),
          _ActionPill(
            icon: Icons.qr_code_scanner_rounded, 
            label: 'Scan',
            onTap: () {
              if (currentWalletId != null) {
                context.push(AppRouter.scanner, extra: currentWalletId);
              }
            },
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildSpendingChart(List<TransactionEntity> transactions) {
    // Calculate spending for the last 7 days
    final now = DateTime.now();
    final List<double> dailySpending = List.filled(7, 0.0);
    
    for (var tx in transactions) {
      if (tx.type == TransactionType.expense) {
        final difference = now.difference(tx.transactionDate).inDays;
        if (difference >= 0 && difference < 7) {
          dailySpending[6 - difference] += tx.amount;
        }
      }
    }
    
    // Normalize heights (max height = 100)
    final maxSpending = dailySpending.isEmpty ? 1.0 : dailySpending.reduce((a, b) => a > b ? a : b);
    final normalizedHeights = dailySpending.map((amount) {
      return maxSpending > 0 ? (amount / maxSpending) * 100 : 10.0;
    }).toList();

    return GlassCard(
      height: 200,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending Trend',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.more_horiz, color: AppColors.textSecondaryDark),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              return Container(
                width: 30,
                height: normalizedHeights[index].clamp(5.0, 100.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ).animate().scaleY(
                delay: (600 + index * 50).ms,
                duration: 400.ms,
                begin: 0,
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 800.ms);
  }

  Widget _buildBudgetSummary(BuildContext context, List<TransactionEntity> transactions, List<CategoryEntity> categories) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        if (state is BudgetsLoaded && state.budgets.isNotEmpty) {
          final budget = state.budgets.first; // Show the most important or first one
          final category = categories.cast<CategoryEntity>().firstWhere(
            (c) => c.id == budget.categoryId,
            orElse: () => const CategoryEntity(id: '', name: 'Unknown', type: '', icon: 'default'),
          );
          
          final spent = transactions
              .where((tx) => tx.categoryId == budget.categoryId && tx.type == TransactionType.expense)
              .fold(0.0, (sum, tx) => sum + tx.amount);
          
          final percent = (spent / budget.amountLimit).clamp(0.0, 1.0);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Budget Status',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => context.push(AppRouter.budgets),
                    child: const Text('View All', style: TextStyle(color: AppColors.primary, fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(category.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${spent.toStringAsFixed(0)} / \$${budget.amountLimit.toStringAsFixed(0)}', 
                              style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                            if (spent > budget.amountLimit)
                              const Text('Over!', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold))
                            else if (percent > 0.8)
                              const Text('Near!', style: TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          spent > budget.amountLimit ? Colors.redAccent : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRecentActivity(List<TransactionEntity> transactions, List<CategoryEntity> categories) {
    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final recentTxs = transactions.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'See All',
              style: TextStyle(color: AppColors.primary, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...recentTxs.map((tx) {
          final category = categories.cast<CategoryEntity>().firstWhere(
            (c) => c.id == tx.categoryId,
            orElse: () => const CategoryEntity(id: '', name: 'Transaction', type: '', icon: 'default'),
          );
          
          return _ActivityItem(
            icon: IconHelper.getIconData(category.icon, category.name),
            title: tx.note.isEmpty ? category.name : tx.note,
            subtitle: '${tx.transactionDate.day}/${tx.transactionDate.month}/${tx.transactionDate.year}',
            amount: '${tx.type == TransactionType.income ? '+' : '-'} \$${tx.amount.toStringAsFixed(2)}',
            isPositive: tx.type == TransactionType.income,
          );
        }),
      ],
    ).animate().fadeIn(delay: 800.ms, duration: 800.ms);
  }

  // Icon mapping moved to IconHelper

}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionPill({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          GlassCard(
            hasBlur: false, // Performance optimization
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(50),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final bool isPositive;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.isPositive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        hasBlur: false, // Performance optimization
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    subtitle,
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
    );
  }
}
