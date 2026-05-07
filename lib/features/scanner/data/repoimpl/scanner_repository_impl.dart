import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../domain/entities/scanned_receipt_entity.dart';
import '../../domain/repo/scanner_repository.dart';

class ScannerRepositoryImpl implements ScannerRepository {
  final TextRecognizer _textRecognizer;

  ScannerRepositoryImpl({TextRecognizer? textRecognizer})
      : _textRecognizer = textRecognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<Either<String, ScannedReceiptEntity>> processImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return const Left('Image file not found');
      }

      final inputImage = InputImage.fromFile(file);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      final parsedData = _parseReceipt(recognizedText.text);

      return Right(parsedData);
    } catch (e) {
      return Left('Failed to process image: ${e.toString()}');
    }
  }

  ScannedReceiptEntity _parseReceipt(String fullText) {
    if (fullText.isEmpty) {
      return const ScannedReceiptEntity(fullText: '');
    }

    final lines = fullText.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    // 1. Try to find the vendor/note (usually the first line)
    String? note;
    if (lines.isNotEmpty) {
      note = lines.first;
    }

    // 2. Try to find the largest monetary amount as the total
    double? maxAmount;
    final amountRegex = RegExp(r'\$?\s*(\d+[\.,]\d{2})');
    
    for (var line in lines) {
      final matches = amountRegex.allMatches(line);
      for (var match in matches) {
        final amountStr = match.group(1)?.replaceAll(',', '.');
        if (amountStr != null) {
          final amount = double.tryParse(amountStr);
          if (amount != null) {
            if (maxAmount == null || amount > maxAmount) {
              maxAmount = amount;
            }
          }
        }
      }
    }

    return ScannedReceiptEntity(
      extractedNote: note,
      extractedAmount: maxAmount,
      fullText: fullText,
    );
  }
}
