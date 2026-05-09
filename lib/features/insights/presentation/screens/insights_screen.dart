import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_state.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/services/insights_service.dart';
import '../bloc/insights_bloc.dart';
import '../bloc/insights_event.dart';
import '../bloc/insights_state.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/widgets/custom_components.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../features/wallet/presentation/bloc/wallet_bloc.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            } else if (state is TransactionsLoaded) {
              return BlocBuilder<WalletBloc, WalletState>(
                builder: (context, walletState) {
                  String currencyCode = 'USD';
                  if (walletState is WalletsLoaded && walletState.wallets.isNotEmpty) {
                    // We assume the transactions are for the first/selected wallet in real app logic
                    // For now, we'll try to find the wallet that matches the first transaction's walletId
                    if (state.transactions.isNotEmpty) {
                      final wallet = walletState.wallets.firstWhere(
                        (w) => w.id == state.transactions.first.walletId,
                        orElse: () => walletState.wallets.first,
                      );
                      currencyCode = wallet.currency;
                    } else {
                      currencyCode = walletState.wallets.first.currency;
                    }
                  }
                  
                  // Trigger AI insights generation
                  context.read<InsightsBloc>().add(GenerateInsights(state.transactions));
                  
                  return _buildContent(context, state.transactions, currencyCode);
                },
              );
            } else {
              return const Center(child: Text('No data available', style: TextStyle(color: Colors.white)));
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<TransactionEntity> transactions, String currencyCode) {
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
    final income = transactions.where((t) => t.type == TransactionType.income).toList();

    final totalExpense = expenses.fold(0.0, (sum, item) => sum + item.amount);
    final totalIncome = income.fold(0.0, (sum, item) => sum + item.amount);
    final balance = totalIncome - totalExpense;
    final symbol = sl<CurrencyService>().getSymbol(currencyCode);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Insights',
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildSummaryCards(totalIncome, totalExpense, balance, symbol),
                const SizedBox(height: 32),
                _buildSectionHeader('Spending by Category'),
                const SizedBox(height: 16),
                _buildCategoryPieChart(expenses, symbol),
                const SizedBox(height: 32),
                _buildSectionHeader('AI Recommendations'),
                const SizedBox(height: 16),
                _buildAiTips(transactions),
                const SizedBox(height: 32),
                _buildSectionHeader('Smart Goals (AI Proposed)'),
                const SizedBox(height: 16),
                _buildSmartGoals(),
                const SizedBox(height: 32),
                _buildSectionHeader('Monthly Trend'),
                const SizedBox(height: 16),
                _buildMonthlyBarChart(transactions),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildSummaryCards(double income, double expense, double balance, String symbol) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            'Income',
            '$symbol${NumberFormat("#,##0").format(income)}',
            AppColors.secondary,
            Icons.arrow_upward,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryItem(
            'Expense',
            '$symbol${NumberFormat("#,##0").format(expense)}',
            AppColors.error,
            Icons.arrow_downward,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart(List<TransactionEntity> expenses, String symbol) {
    if (expenses.isEmpty) {
      return const Center(child: Text('No expenses recorded', style: TextStyle(color: Colors.white70)));
    }

    final categoryMap = <String, double>{};
    for (var exp in expenses) {
      categoryMap[exp.categoryId] = (categoryMap[exp.categoryId] ?? 0.0) + exp.amount;
    }

    final sortedEntries = categoryMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final displayEntries = sortedEntries.take(5).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: displayEntries.asMap().entries.map((entry) {
                  final color = _getChartColor(entry.key);
                  return PieChartSectionData(
                    color: color,
                    value: entry.value.value,
                    title: '',
                    radius: 50,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: displayEntries.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: _getChartColor(entry.key), shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Category', style: const TextStyle(color: Colors.white, fontSize: 12), overflow: TextOverflow.ellipsis)),
                      Text('$symbol${entry.value.value.toInt()}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBarChart(List<TransactionEntity> transactions) {
    // Group by month
    final last6MonthsMap = <String, double>{};
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthName = DateFormat('MMM').format(monthDate);
      last6MonthsMap[monthName] = 0.0;
    }

    for (var t in transactions) {
      if (t.type == TransactionType.expense) {
        final monthName = DateFormat('MMM').format(t.transactionDate);
        if (last6MonthsMap.containsKey(monthName)) {
          last6MonthsMap[monthName] = last6MonthsMap[monthName]! + t.amount;
        }
      }
    }

    final last6MonthsList = last6MonthsMap.entries.toList();

    final barGroups = last6MonthsList.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.value,
            color: AppColors.primary,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true, 
              toY: 1.2 * (last6MonthsMap.values.isNotEmpty ? last6MonthsMap.values.reduce((a, b) => a > b ? a : b) : 100), 
              color: Colors.white.withValues(alpha: 0.05)
            ),
          ),
        ],
      );
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 1.2 * (last6MonthsMap.values.isNotEmpty ? last6MonthsMap.values.reduce((a, b) => a > b ? a : b) : 100),
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < last6MonthsList.length) {
                    final month = last6MonthsList[value.toInt()].key;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(month, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }

  Widget _buildAiTips(List<TransactionEntity> transactions) {
    return BlocBuilder<InsightsBloc, InsightsState>(
      builder: (context, state) {
        List<String> tips = [];
        bool isLoading = false;

        if (state is InsightsLoading) {
          isLoading = true;
        } else if (state is InsightsLoaded) {
          tips = state.insights;
        } else {
          // Fallback to rule-based tips while AI is loading or if it fails
          tips = InsightsService.generateTips(transactions);
        }

        return Column(
          children: [
            if (isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              )),
            ...tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                borderColor: AppColors.primary.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.primary, size: 24)
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 2.seconds, color: Colors.white.withValues(alpha: 0.2)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0);
      },
    );
  }

  Color _getChartColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      const Color(0xFF6C5CE7),
      const Color(0xFF00B894),
      const Color(0xFFFDCB6E),
    ];
    return colors[index % colors.length];
  }
  Widget _buildSmartGoals() {
    return BlocBuilder<InsightsBloc, InsightsState>(
      builder: (context, state) {
        if (state is InsightsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is InsightsLoaded && state.suggestedGoals.isNotEmpty) {
          return Column(
            children: state.suggestedGoals.map((goal) {
              final isSavings = goal['type'] == 'savings';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isSavings ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSavings ? Icons.savings_rounded : Icons.track_changes_rounded,
                          color: isSavings ? AppColors.secondary : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal['title'] ?? 'Goal',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              goal['description'] ?? '',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${goal['targetAmount']}',
                            style: TextStyle(
                              color: isSavings ? AppColors.secondary : AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Target',
                            style: TextStyle(color: Colors.white38, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }
        return const Center(child: Text('No goals suggested yet.', style: TextStyle(color: Colors.white70)));
      },
    );
  }
}
