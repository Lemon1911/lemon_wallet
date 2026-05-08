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
    
    // 1. Try to find the vendor (usually the first few lines, avoiding common headers)
    String? note;
    final commonHeaders = ['receipt', 'tax invoice', 'invoice', 'order', 'sale', 'customer'];
    for (var line in lines.take(3)) {
      if (!commonHeaders.any((header) => line.toLowerCase().contains(header))) {
        note = line;
        break;
      }
    }

    // 2. Find the total amount
    double? totalAmount;
    final totalKeywords = ['total', 'amount due', 'balance', 'grand total', 'net total'];
    final amountRegex = RegExp(r'(\d+[\.,]\s?\d{2})');
    
    for (var i = lines.length - 1; i >= 0; i--) {
      final line = lines[i].toLowerCase();
      if (totalKeywords.any((kw) => line.contains(kw))) {
        final matches = amountRegex.allMatches(line);
        if (matches.isNotEmpty) {
          final amountStr = matches.last.group(1)?.replaceAll(RegExp(r'\s'), '').replaceAll(',', '.');
          if (amountStr != null) {
            totalAmount = double.tryParse(amountStr);
            if (totalAmount != null) break;
          }
        }
        // If not in same line, check next line (often total is below the keyword)
        if (i + 1 < lines.length) {
          final nextLine = lines[i+1];
          final nextMatches = amountRegex.allMatches(nextLine);
          if (nextMatches.isNotEmpty) {
            final amountStr = nextMatches.first.group(1)?.replaceAll(RegExp(r'\s'), '').replaceAll(',', '.');
            if (amountStr != null) {
              totalAmount = double.tryParse(amountStr);
              if (totalAmount != null) break;
            }
          }
        }
      }
    }

    // Fallback: Use the largest amount found in the receipt
    if (totalAmount == null) {
      double maxFound = 0;
      for (var line in lines) {
        final matches = amountRegex.allMatches(line);
        for (var m in matches) {
          final s = m.group(1)?.replaceAll(RegExp(r'\s'), '').replaceAll(',', '.');
          final a = double.tryParse(s ?? '');
          if (a != null && a > maxFound) maxFound = a;
        }
      }
      if (maxFound > 0) totalAmount = maxFound;
    }

    return ScannedReceiptEntity(
      extractedNote: note ?? (lines.isNotEmpty ? lines.first : 'Scanned Receipt'),
      extractedAmount: totalAmount,
      fullText: fullText,
    );
  }
}
