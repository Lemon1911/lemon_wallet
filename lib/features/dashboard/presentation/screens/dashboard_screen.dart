import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_components.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        if (state is WalletLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WalletsLoaded && state.wallets.isEmpty) {
          return _buildEmptyState(context);
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<WalletBloc>().add(LoadWallets());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 32),
                    _buildBalanceSection(state is WalletsLoaded ? state.wallets : []),
                    const SizedBox(height: 32),
                    _buildQuickActions(context, state is WalletsLoaded ? state.wallets : []),
                    const SizedBox(height: 32),
                    _buildSpendingChart(),
                    const SizedBox(height: 32),
                    _buildRecentActivity(),
                  ],
                ),
              ),
            ),
          ),
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

  Widget _buildBalanceSection(List<WalletEntity> wallets) {
    // For now, just sum up or show first wallet. In a real app, you'd fetch total balance.
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Balance',
              style: TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$',
                  style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.7),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '0.00', // Real balance integration later
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
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

  Widget _buildQuickActions(BuildContext context, List<WalletEntity> wallets) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionPill(icon: Icons.send_rounded, label: 'Send'),
        _ActionPill(
          icon: Icons.add_rounded, 
          label: 'Income',
          onTap: () {
            if (wallets.isNotEmpty) {
              context.push(AppRouter.addTransaction, extra: wallets.first.id);
            }
          },
        ),
        _ActionPill(icon: Icons.payment_rounded, label: 'Pay'),
        _ActionPill(icon: Icons.more_horiz_rounded, label: 'More'),
      ],
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildSpendingChart() {
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
          // Placeholder for Chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              final height = [40, 70, 50, 90, 60, 80, 45][index];
              return Container(
                width: 30,
                height: height.toDouble(),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.8),
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

  Widget _buildRecentActivity() {
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
        _ActivityItem(
          icon: Icons.shopping_bag_rounded,
          title: 'Apple Store',
          subtitle: 'Today, 10:45 AM',
          amount: '- \$999.00',
        ),
        _ActivityItem(
          icon: Icons.coffee_rounded,
          title: 'Starbucks',
          subtitle: 'Yesterday, 08:20 PM',
          amount: '- \$12.50',
        ),
        _ActivityItem(
          icon: Icons.trending_up_rounded,
          title: 'Dividend Pay',
          subtitle: '2 days ago',
          amount: '+ \$250.00',
          isPositive: true,
        ),
      ],
    ).animate().fadeIn(delay: 800.ms, duration: 800.ms);
  }
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
