import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_components.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../../../wallet/presentation/bloc/wallet_bloc.dart';
import '../../../../core/utils/icon_helper.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/di/service_locator.dart';

class AddTransactionScreen extends StatefulWidget {
  final String walletId;
  final TransactionType? initialType;
  final double? initialAmount;
  final String? initialNote;
  
  const AddTransactionScreen({
    super.key, 
    required this.walletId,
    this.initialType,
    this.initialAmount,
    this.initialNote,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late TransactionType _type;
  CategoryEntity? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? TransactionType.expense;
    if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount.toString();
    }
    if (widget.initialNote != null) {
      _noteController.text = widget.initialNote!;
    }
    context.read<TransactionBloc>().add(LoadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Add Transaction', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionSuccess) {
            context.pop();
            context.read<TransactionBloc>().add(LoadTransactions(widget.walletId));
            context.read<WalletBloc>().add(LoadWallets());
          } else if (state is TransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeToggle(),
              const SizedBox(height: 32),
              _buildAmountInput(),
              const SizedBox(height: 32),
              const Text('Category', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16)),
              const SizedBox(height: 12),
              _buildCategorySelector(),
              const SizedBox(height: 32),
              const Text('Note', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16)),
              const SizedBox(height: 12),
              GlassCard(
                child: TextField(
                  controller: _noteController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'What was this for?',
                    hintStyle: TextStyle(color: AppColors.textSecondaryDark),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildDatePicker(),
              const SizedBox(height: 48),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _type = TransactionType.expense),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 12),
              border: _type == TransactionType.expense ? Border.all(color: Colors.redAccent, width: 2) : null,
              child: Center(
                child: Text('Expense', 
                  style: TextStyle(color: _type == TransactionType.expense ? Colors.redAccent : Colors.white70, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _type = TransactionType.income),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 12),
              border: _type == TransactionType.income ? Border.all(color: AppColors.primary, width: 2) : null,
              child: Center(
                child: Text('Income', 
                  style: TextStyle(color: _type == TransactionType.income ? AppColors.primary : Colors.white70, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Amount', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16)),
        const SizedBox(height: 12),
        Row(
          children: [
            BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                String symbol = '\$';
                if (state is WalletsLoaded) {
                  final wallet = state.wallets.firstWhere((w) => w.id == widget.walletId, orElse: () => state.wallets.first);
                  symbol = sl<CurrencyService>().getSymbol(wallet.currency);
                }
                return Text(symbol, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold));
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(color: Colors.white24),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      buildWhen: (previous, current) => current is CategoriesLoaded || current is TransactionLoading,
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CategoriesLoaded) {
          final filteredCategories = state.categories.where((c) => c.type == (_type == TransactionType.income ? 'income' : 'expense')).toList();
          
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: filteredCategories.map((cat) {
              final isSelected = _selectedCategory?.id == cat.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(IconHelper.getIconData(cat.icon), color: isSelected ? AppColors.primary : Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Text(cat.name, style: TextStyle(color: isSelected ? AppColors.primary : Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }
        return const Text('Error loading categories', style: TextStyle(color: Colors.redAccent));
      },
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Date', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16)),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          if (_amountController.text.isNotEmpty && _selectedCategory != null) {
            context.read<TransactionBloc>().add(
              AddTransaction(
                walletId: widget.walletId,
                categoryId: _selectedCategory!.id,
                amount: double.parse(_amountController.text),
                type: _type,
                note: _noteController.text,
                transactionDate: _selectedDate,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const CircularProgressIndicator(color: AppColors.backgroundDark);
            }
            return const Text('Add Transaction', 
              style: TextStyle(color: AppColors.backgroundDark, fontWeight: FontWeight.bold, fontSize: 18));
          },
        ),
      ),
    );
  }

  // Icon mapping moved to IconHelper

}
