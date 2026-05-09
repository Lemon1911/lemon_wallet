import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_components.dart';
import '../../../../core/di/service_locator.dart';
import '../../features/transactions/domain/usecase/transaction_usecases.dart';
import '../../features/transactions/domain/entities/transaction_entity.dart';
import '../../features/wallet/domain/entities/wallet_entity.dart';

class ConfirmTransactionDialog extends StatelessWidget {
  final double amount;
  final String merchant;
  final WalletEntity wallet;

  const ConfirmTransactionDialog({
    super.key,
    required this.amount,
    required this.merchant,
    required this.wallet,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Confirm Transaction',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'A transaction of ${wallet.currency} $amount at $merchant was detected.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Dismiss', style: TextStyle(color: Colors.white70)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final addTx = sl<AddTransactionUseCase>();
                      await addTx(
                        walletId: wallet.id,
                        amount: amount,
                        type: TransactionType.expense,
                        categoryId: 'default', // Should ideally allow selecting category
                        transactionDate: DateTime.now(),
                        note: 'Detected via SMS from $merchant',
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Confirm', style: TextStyle(color: AppColors.backgroundDark, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
