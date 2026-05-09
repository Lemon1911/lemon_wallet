import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_components.dart';
import '../../../../core/router/app_router.dart';
import '../bloc/wallet_bloc.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/widgets/skeleton_loaders.dart';
import '../../../../core/di/service_locator.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _currentWalletIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        if (state is WalletLoading) {
          return _buildLoadingState();
        }
        List<WalletEntity> wallets = [];
        if (state is WalletsLoaded) {
          wallets = state.wallets;
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildCardCarousel(wallets),
                  const SizedBox(height: 32),
                  if (wallets.isNotEmpty) ...[
                    _buildVirtualCardDetails(wallets[_currentWalletIndex]),
                    const SizedBox(height: 32),
                    _buildCollaborators(wallets[_currentWalletIndex]),
                    const SizedBox(height: 32),
                  ],
                  _buildLinkedBanks(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(width: 120, height: 28),
                  SizedBox(height: 8),
                  SkeletonLoader(width: 200, height: 16),
                ],
              ),
              SkeletonLoader(width: 40, height: 40, borderRadius: BorderRadius.all(Radius.circular(20))),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              SkeletonLoader(width: 320, height: 220, borderRadius: BorderRadius.circular(24)),
              const SizedBox(width: 16),
              const SkeletonLoader(width: 50, height: 220, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), bottomLeft: Radius.circular(24))),
            ],
          ),
          const SizedBox(height: 32),
          SkeletonLoader.card(height: 250),
          const SizedBox(height: 32),
          const SkeletonLoader(width: 150, height: 24),
          const SizedBox(height: 16),
          List.generate(3, (_) => SkeletonLoader.listTile()).reduce((a, b) => Column(children: [a, b])),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Wallet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Manage your digital assets',
              style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
            ),
          ],
        ),
        IconButton(
          onPressed: () => context.push(AppRouter.createWallet),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: AppColors.primary),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildCardCarousel(List<WalletEntity> wallets) {
    if (wallets.isEmpty) {
      return GlassCard(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No wallets found', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Create First Wallet',
                onPressed: () => context.push(AppRouter.createWallet),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: wallets.length,
            itemBuilder: (context, index) {
              final wallet = wallets[index];
              final isSelected = _currentWalletIndex == index;
              
              return GestureDetector(
                onTap: () => setState(() => _currentWalletIndex = index),
                child: Container(
                  width: 320,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isSelected
                          ? [AppColors.primary, AppColors.accent]
                          : [AppColors.accent.withValues(alpha: 0.5), AppColors.bgDark],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: isSelected ? Border.all(color: Colors.white24) : null,
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            wallet.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Icon(
                            index % 2 == 0
                                ? Icons.credit_card
                                : Icons.account_balance,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${wallet.currency} WALLET',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '**** **** **** ${wallet.id.length >= 4 ? wallet.id.substring(wallet.id.length - 4).toUpperCase() : 'NEW'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildVirtualCardDetails(WalletEntity wallet) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${wallet.name} Details',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.security, color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow('Wallet ID', wallet.id.toUpperCase()),
          const Divider(color: AppColors.glassBorder, height: 24),
          _buildDetailRow('Currency', '${wallet.currency} (${sl<CurrencyService>().getSymbol(wallet.currency)})'),
          const Divider(color: AppColors.glassBorder, height: 24),
          _buildDetailRow('Created At', '${wallet.createdAt.day}/${wallet.createdAt.month}/${wallet.createdAt.year}'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Set as Primary',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.bgDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Edit Wallet',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 800.ms);
  }

  Widget _buildLinkedBanks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Linked Bank Accounts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildBankItem('Chase Bank', '.... 4412'),
        _buildBankItem('Bank of America', '.... 9901'),
      ],
    ).animate().fadeIn(delay: 600.ms, duration: 800.ms);
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondaryDark)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankItem(String name, String accountNumber) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white10,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    accountNumber,
                    style: TextStyle(
                      color: AppColors.textSecondaryDark,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildCollaborators(WalletEntity wallet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Collaborators',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showInviteDialog(context, wallet),
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('Invite'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (wallet.members.isEmpty)
          const Center(
            child: Text(
              'No collaborators yet',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          )
        else
          ...wallet.members.map((member) => _buildMemberItem(wallet, member)),
      ],
    );
  }

  Widget _buildMemberItem(WalletEntity wallet, dynamic member) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.fullName ?? member.username ?? 'Member',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    member.role.name.toUpperCase(),
                    style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 10, letterSpacing: 1),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white24),
              onPressed: () => _showMemberOptions(context, wallet, member),
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteDialog(BuildContext context, WalletEntity wallet) {
    final controller = TextEditingController();
    String selectedRole = 'viewer';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: GlassCard(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Invite Member', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Invite a user to collaborate on ${wallet.name}', style: TextStyle(color: AppColors.textSecondaryDark)),
                const SizedBox(height: 24),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Username or Email',
                    labelStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.alternate_email_rounded, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  dropdownColor: AppColors.bgDark,
                  decoration: const InputDecoration(labelText: 'Role', labelStyle: TextStyle(color: Colors.white70)),
                  items: ['admin', 'viewer'].map((role) => DropdownMenuItem(value: role, child: Text(role.toUpperCase(), style: const TextStyle(color: Colors.white)))).toList(),
                  onChanged: (val) => setModalState(() => selectedRole = val!),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        context.read<WalletBloc>().add(InviteMember(
                          walletId: wallet.id,
                          email: controller.text,
                          role: selectedRole,
                        ));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sending invitation...')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Send Invitation', style: TextStyle(color: AppColors.bgDark, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMemberOptions(BuildContext context, WalletEntity wallet, dynamic member) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_remove_rounded, color: AppColors.error),
              title: const Text('Remove from Wallet', style: TextStyle(color: AppColors.error)),
              onTap: () {
                // TODO: Implement remove member logic in WalletBloc
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shield_rounded, color: Colors.white),
              title: const Text('Change Role', style: TextStyle(color: Colors.white)),
              onTap: () {
                // TODO: Implement change role logic
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
