import 'package:equatable/equatable.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object> get props => [];
}

class ProcessImageEvent extends ScannerEvent {
  final String imagePath;

  const ProcessImageEvent(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}
