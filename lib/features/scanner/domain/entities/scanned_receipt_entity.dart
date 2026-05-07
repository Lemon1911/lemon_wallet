import 'package:equatable/equatable.dart';

class ScannedReceiptEntity extends Equatable {
  final double? extractedAmount;
  final String? extractedNote;
  final String fullText;

  const ScannedReceiptEntity({
    this.extractedAmount,
    this.extractedNote,
    required this.fullText,
  });

  @override
  List<Object?> get props => [extractedAmount, extractedNote, fullText];
}
