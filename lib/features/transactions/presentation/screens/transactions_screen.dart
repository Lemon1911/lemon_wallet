import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_components.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSearchBar(),
          const SizedBox(height: 32),
          _buildGroupHeader('Today'),
          const SizedBox(height: 16),
          _buildTransactionItem(
            icon: Icons.shopping_bag_rounded,
            title: 'Apple Store',
            time: '10:45 AM',
            amount: '- \$999.00',
          ),
          _buildTransactionItem(
            icon: Icons.fastfood_rounded,
            title: 'McDonald\'s',
            time: '09:30 AM',
            amount: '- \$15.20',
          ),
          const SizedBox(height: 24),
          _buildGroupHeader('Yesterday'),
          const SizedBox(height: 16),
          _buildTransactionItem(
            icon: Icons.coffee_rounded,
            title: 'Starbucks',
            time: '08:20 PM',
            amount: '- \$12.50',
          ),
          _buildTransactionItem(
            icon: Icons.trending_up_rounded,
            title: 'Dividend Pay',
            time: '02:15 PM',
            amount: '+ \$250.00',
            isPositive: true,
          ),
          _buildTransactionItem(
            icon: Icons.electric_bolt_rounded,
            title: 'Electric Bill',
            time: '11:00 AM',
            amount: '- \$85.00',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
        GlassCard(
          padding: const EdgeInsets.all(10),
          borderRadius: BorderRadius.circular(12),
          child: const Icon(Icons.filter_list_rounded, color: Colors.white, size: 20),
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
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondaryDark),
          border: InputBorder.none,
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildGroupHeader(String label) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.textSecondaryDark,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
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
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    time,
                    style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
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
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.1, end: 0);
  }
}
