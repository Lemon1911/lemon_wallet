import '../../../transactions/domain/entities/transaction_entity.dart';

class InsightsService {
  static List<String> generateTips(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) return ['Start adding transactions to get AI-powered financial tips!'];

    final tips = <String>[];
    final now = DateTime.now();
    final thisMonth = transactions.where((t) => t.transactionDate.month == now.month && t.transactionDate.year == now.year).toList();
    final lastMonth = transactions.where((t) => t.transactionDate.month == (now.month == 1 ? 12 : now.month - 1)).toList();

    final thisMonthExpense = thisMonth.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);
    final lastMonthExpense = lastMonth.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);

    // Tip 1: Monthly Comparison
    if (lastMonthExpense > 0) {
      final diff = ((thisMonthExpense - lastMonthExpense) / lastMonthExpense) * 100;
      if (diff > 10) {
        tips.add('Warning: Your spending is up ${diff.toStringAsFixed(1)}% compared to last month. Consider reviewing your "Other" expenses.');
      } else if (diff < -5) {
        tips.add('Great job! You spent ${diff.abs().toStringAsFixed(1)}% less than last month. Keep it up!');
      }
    }

    // Tip 2: Category Concentration
    final categoryTotals = <String, double>{};
    for (var t in thisMonth.where((t) => t.type == TransactionType.expense)) {
      categoryTotals[t.categoryId] = (categoryTotals[t.categoryId] ?? 0) + t.amount;
    }

    if (categoryTotals.isNotEmpty) {
      final topCategory = categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
      final percentage = (topCategory.value / thisMonthExpense) * 100;
      if (percentage > 40) {
        tips.add('Insight: One category accounts for ${percentage.toStringAsFixed(0)}% of your monthly spending. Try to diversify your budget.');
      }
    }

    // Tip 3: Savings Rate
    final totalIncome = thisMonth.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
    if (totalIncome > 0) {
      final savingsRate = ((totalIncome - thisMonthExpense) / totalIncome) * 100;
      if (savingsRate > 20) {
        tips.add('Smart Saver: You saved ${savingsRate.toStringAsFixed(1)}% of your income this month. You are on track for your financial goals!');
      } else if (savingsRate < 5 && savingsRate > 0) {
        tips.add('Tip: Your savings rate is below 5%. Try the 50/30/20 rule to improve your financial health.');
      }
    }

    // Default tip if list is short
    if (tips.length < 2) {
      tips.add('Pro Tip: Setting up monthly budgets can help you stay disciplined with your spending.');
    }

    return tips;
  }
}
