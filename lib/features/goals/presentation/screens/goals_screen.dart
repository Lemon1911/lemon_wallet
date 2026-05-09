import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_components.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/goal_bloc.dart';
import '../bloc/goal_event.dart';
import '../bloc/goal_state.dart';
import '../../domain/entities/goal_entity.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GoalBloc>().add(LoadGoals());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Financial Goals', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: AppColors.primary),
            onPressed: () => context.read<GoalBloc>().add(SyncGoals()),
          ),
        ],
      ),
      body: BlocConsumer<GoalBloc, GoalState>(
        listener: (context, state) {
          if (state is GoalOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.primary),
            );
          } else if (state is GoalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is GoalLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is GoalLoaded) {
            if (state.goals.isEmpty) {
              return _buildEmptyState();
            }
            return _buildGoalsList(state.goals);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push(AppRouter.addGoal),
        child: const Icon(Icons.add, color: AppColors.backgroundDark),
      ).animate().scale(delay: 400.ms, duration: 400.ms),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Icon(Icons.flag_rounded, size: 64, color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Goals Yet',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Set your first financial goal and start saving!',
            style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildGoalsList(List<GoalEntity> goals) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return _GoalCard(goal: goal).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
      },
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalEntity goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = goal.progress;
    final isCompleted = progress >= 1.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Dismissible(
        key: Key(goal.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.delete_outline, color: AppColors.error),
        ),
        onDismissed: (_) {
          context.read<GoalBloc>().add(DeleteGoal(goal.id));
        },
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (goal.description.isNotEmpty)
                          Text(
                            goal.description,
                            style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    const Icon(Icons.check_circle, color: AppColors.primary)
                  else
                    Icon(
                      goal.type == GoalType.savings ? Icons.savings_outlined : Icons.account_balance_wallet_outlined,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${goal.currentAmount.toStringAsFixed(0)} / \$${goal.targetAmount.toStringAsFixed(0)}',
                    style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? AppColors.primary : AppColors.primary.withValues(alpha: 0.8),
                  ),
                ),
              ),
              if (goal.deadline != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondaryDark),
                    const SizedBox(width: 6),
                    Text(
                      'Deadline: ${goal.deadline!.day}/${goal.deadline!.month}/${goal.deadline!.year}',
                      style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
