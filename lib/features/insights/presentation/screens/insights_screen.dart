import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/transactions/presentation/bloc/transaction_bloc.dart';
import '../../../../features/transactions/presentation/bloc/transaction_state.dart';
import '../../../../features/transactions/domain/entities/transaction_entity.dart';

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
              final transactions = state.transactions;
              return _buildContent(context, transactions);
            } else {
              return const Center(child: Text('No data available', style: TextStyle(color: Colors.white)));
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<TransactionEntity> transactions) {
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
    final income = transactions.where((t) => t.type == TransactionType.income).toList();

    final totalExpense = expenses.fold(0.0, (sum, item) => sum + item.amount);
    final totalIncome = income.fold(0.0, (sum, item) => sum + item.amount);
    final balance = totalIncome - totalExpense;

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
                _buildSummaryCards(totalIncome, totalExpense, balance),
                const SizedBox(height: 32),
                _buildSectionHeader('Spending by Category'),
                const SizedBox(height: 16),
                _buildCategoryPieChart(expenses),
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

  Widget _buildSummaryCards(double income, double expense, double balance) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            'Income',
            '\$${NumberFormat("#,##0").format(income)}',
            AppColors.secondary,
            Icons.arrow_upward,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryItem(
            'Expense',
            '\$${NumberFormat("#,##0").format(expense)}',
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

  Widget _buildCategoryPieChart(List<TransactionEntity> expenses) {
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
                      Text('\$${entry.value.value.toInt()}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
}
