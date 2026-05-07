import 'package:equatable/equatable.dart';
import '../../domain/entities/scanned_receipt_entity.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();
  
  @override
  List<Object> get props => [];
}

class ScannerInitial extends ScannerState {}

class ScannerLoading extends ScannerState {}

class ScannerSuccess extends ScannerState {
  final ScannedReceiptEntity receipt;

  const ScannerSuccess(this.receipt);

  @override
  List<Object> get props => [receipt];
}

class ScannerFailure extends ScannerState {
  final String message;

  const ScannerFailure(this.message);

  @override
  List<Object> get props => [message];
}
