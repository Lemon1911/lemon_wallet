import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_components.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_state.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/domain/entities/category_entity.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';
import '../../domain/entities/budget_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BudgetBloc>().add(LoadBudgets());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        return BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, txState) {
            if (state is BudgetLoading || txState is TransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BudgetsLoaded && txState is TransactionsLoaded) {
              return _buildBudgetList(context, state.budgets, txState.transactions, txState.categories);
            }

            return const Center(child: Text('Something went wrong'));
          },
        );
      },
    );
  }

  Widget _buildBudgetList(
    BuildContext context,
    List<BudgetEntity> budgets,
    List<TransactionEntity> transactions,
    List<CategoryEntity> categories,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, categories),
              const SizedBox(height: 32),
              if (budgets.isEmpty)
                _buildEmptyState()
              else
                ...budgets.map((budget) {
                  final category = categories.cast<CategoryEntity>().firstWhere(
                    (c) => c.id == budget.categoryId,
                    orElse: () => const CategoryEntity(id: '', name: 'Unknown', type: '', icon: 'default'),
                  );
                  
                  final spent = transactions
                      .where((tx) => tx.categoryId == budget.categoryId && tx.type == TransactionType.expense)
                      .fold(0.0, (sum, tx) => sum + tx.amount);

                  return _buildBudgetItem(context, budget, category, spent);
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, List<CategoryEntity> categories) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budgets',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              '${categories.length} categories tracked',
              style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
            ),
          ],
        ),
        FloatingActionButton.small(
          onPressed: () => _showAddBudgetDialog(context, categories),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: AppColors.backgroundDark),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text('No budgets set yet', style: TextStyle(color: AppColors.textSecondaryDark)),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(BuildContext context, BudgetEntity budget, CategoryEntity category, double spent) {
    final percent = (spent / budget.amountLimit).clamp(0.0, 1.0);
    final isOverBudget = spent > budget.amountLimit;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
                  onPressed: () => context.read<BudgetBloc>().add(DeleteBudget(budget.id)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${spent.toStringAsFixed(2)} of \$${budget.amountLimit.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isOverBudget ? Colors.redAccent : AppColors.textSecondaryDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isOverBudget)
                      const Text(
                        'Over budget!',
                        style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      )
                    else if (percent > 0.8)
                      const Text(
                        'Approaching limit',
                        style: TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                Text(
                  '${(percent * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget ? Colors.redAccent : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  void _showAddBudgetDialog(BuildContext context, List<CategoryEntity> categories) {
    final amountController = TextEditingController();
    CategoryEntity? selectedCategory;
    final budgetBloc = context.read<BudgetBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: GlassCard(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create Budget', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                DropdownButtonFormField<CategoryEntity>(
                  dropdownColor: AppColors.backgroundDark,
                  decoration: const InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: Colors.white70)),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name, style: const TextStyle(color: Colors.white)))).toList(),
                  onChanged: (val) => setState(() => selectedCategory = val),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Monthly Limit', labelStyle: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthAuthenticated && selectedCategory != null && amountController.text.isNotEmpty) {
                        final budget = BudgetEntity(
                          id: const Uuid().v4(),
                          userId: authState.user.id,
                          categoryId: selectedCategory!.id,
                          amountLimit: double.parse(amountController.text),
                          period: 'monthly',
                          startDate: DateTime.now(),
                        );
                        budgetBloc.add(AddBudget(budget));
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save Budget', style: TextStyle(color: AppColors.backgroundDark, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
