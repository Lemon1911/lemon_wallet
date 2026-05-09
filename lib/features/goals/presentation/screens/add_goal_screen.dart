import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_components.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/goal_bloc.dart';
import '../bloc/goal_event.dart';
import '../bloc/goal_state.dart';
import '../../domain/entities/goal_entity.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  GoalType _selectedType = GoalType.savings;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('New Goal', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<GoalBloc, GoalState>(
        listener: (context, state) {
          if (state is GoalOperationSuccess) {
            context.pop();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What are you saving for?',
                  style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Dream Vacation 🌴',
                      hintStyle: TextStyle(color: AppColors.textSecondaryDark),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    validator: (v) => v!.isEmpty ? 'Please enter a title' : null,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Target Amount',
                  style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      prefixText: r'$ ',
                      prefixStyle: TextStyle(color: AppColors.primary, fontSize: 24),
                      hintText: '0.00',
                      hintStyle: TextStyle(color: AppColors.textSecondaryDark),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid amount' : null,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Goal Type',
                  style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _TypeSelector(
                      label: 'Savings',
                      icon: Icons.savings_rounded,
                      isSelected: _selectedType == GoalType.savings,
                      onTap: () => setState(() => _selectedType = GoalType.savings),
                    ),
                    const SizedBox(width: 16),
                    _TypeSelector(
                      label: 'Budget',
                      icon: Icons.account_balance_wallet_rounded,
                      isSelected: _selectedType == GoalType.budget,
                      onTap: () => setState(() => _selectedType = GoalType.budget),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Target Date (Optional)',
                  style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                        const SizedBox(width: 16),
                        Text(
                          _selectedDate == null 
                            ? 'Select a date' 
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: PrimaryButton(
                    text: 'Set Goal',
                    onPressed: _submitForm,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final goal = GoalEntity(
          id: const Uuid().v4(),
          userId: authState.user.id,
          title: _titleController.text,
          description: _descriptionController.text,
          targetAmount: double.parse(_amountController.text),
          currentAmount: 0.0,
          type: _selectedType,
          deadline: _selectedDate,
          createdAt: DateTime.now(),
        );
        context.read<GoalBloc>().add(AddGoal(goal));
      }
    }
  }
}

class _TypeSelector extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeSelector({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 16),
          border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : Colors.white54),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.white54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
