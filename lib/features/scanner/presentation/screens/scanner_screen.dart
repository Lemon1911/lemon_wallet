import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_components.dart';
import '../bloc/scanner_bloc.dart';
import '../bloc/scanner_event.dart';
import '../bloc/scanner_state.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/di/service_locator.dart';

class ScannerScreen extends StatefulWidget {
  final String walletId;
  const ScannerScreen({super.key, required this.walletId});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      if (mounted) {
        context.read<ScannerBloc>().add(ProcessImageEvent(pickedFile.path));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ScannerBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Scan Receipt', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocConsumer<ScannerBloc, ScannerState>(
          listener: (context, state) {
            if (state is ScannerSuccess) {
              // Navigate to AddTransaction and pass the parsed data
              context.go(AppRouter.addTransaction, extra: {
                'walletId': widget.walletId,
                'type': TransactionType.expense,
                'initialAmount': state.receipt.extractedAmount,
                'initialNote': state.receipt.extractedNote,
              });
            } else if (state is ScannerFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
              );
            }
          },
          builder: (context, state) {
            if (state is ScannerLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text('Analyzing Receipt...', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GlassCard(
                    height: 180,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.document_scanner_rounded, size: 64, color: AppColors.primary),
                        const SizedBox(height: 16),
                        const Text(
                          'Scan a receipt to auto-fill your transaction details.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          text: 'Camera',
                          icon: Icons.camera_alt_rounded,
                          onPressed: () => _pickImage(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          text: 'Gallery',
                          icon: Icons.photo_library_rounded,
                          isOutlined: true,
                          onPressed: () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
