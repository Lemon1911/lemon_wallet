import 'package:dartz/dartz.dart';
import '../entities/scanned_receipt_entity.dart';

abstract class ScannerRepository {
  /// Processes an image from the given [imagePath] and extracts receipt information.
  Future<Either<String, ScannedReceiptEntity>> processImage(String imagePath);
}
