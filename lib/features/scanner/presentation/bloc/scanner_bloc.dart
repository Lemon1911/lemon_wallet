import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repo/scanner_repository.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final ScannerRepository scannerRepository;

  ScannerBloc({required this.scannerRepository}) : super(ScannerInitial()) {
    on<ProcessImageEvent>(_onProcessImage);
  }

  Future<void> _onProcessImage(ProcessImageEvent event, Emitter<ScannerState> emit) async {
    emit(ScannerLoading());
    
    final result = await scannerRepository.processImage(event.imagePath);
    
    result.fold(
      (failure) => emit(ScannerFailure(failure)),
      (receipt) => emit(ScannerSuccess(receipt)),
    );
  }
}
