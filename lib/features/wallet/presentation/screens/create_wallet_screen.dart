import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_components.dart';
import '../bloc/wallet_bloc.dart';

class CreateWalletScreen extends StatefulWidget {
  const CreateWalletScreen({super.key});

  @override
  State<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends State<CreateWalletScreen> {
  final _nameController = TextEditingController();
  String _selectedCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Create Wallet', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletSuccess) {
            context.pop();
            context.read<WalletBloc>().add(LoadWallets());
          } else if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Give your wallet a name',
                style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Personal Savings',
                    hintStyle: TextStyle(color: AppColors.textSecondaryDark),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Select Currency',
                style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: ['USD', 'EUR', 'GBP', 'EGP'].map((currency) {
                  final isSelected = _selectedCurrency == currency;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCurrency = currency),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      borderRadius: BorderRadius.circular(30),
                      border: isSelected 
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                      child: Text(
                        currency,
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty) {
                      context.read<WalletBloc>().add(
                        CreateWallet(
                          name: _nameController.text,
                          currency: _selectedCurrency,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: BlocBuilder<WalletBloc, WalletState>(
                    builder: (context, state) {
                      if (state is WalletLoading) {
                        return const CircularProgressIndicator(color: Colors.white);
                      }
                      return const Text(
                        'Create Wallet',
                        style: TextStyle(
                          color: AppColors.backgroundDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
