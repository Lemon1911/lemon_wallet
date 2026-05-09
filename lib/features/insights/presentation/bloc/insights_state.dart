import 'package:equatable/equatable.dart';

abstract class InsightsState extends Equatable {
  const InsightsState();
  @override
  List<Object?> get props => [];
}

class InsightsInitial extends InsightsState {}

class InsightsLoading extends InsightsState {}

class InsightsLoaded extends InsightsState {
  final List<String> insights;
  final List<Map<String, dynamic>> suggestedGoals;
  const InsightsLoaded(this.insights, {this.suggestedGoals = const []});
  @override
  List<Object?> get props => [insights, suggestedGoals];
}

class InsightsError extends InsightsState {
  final String message;
  const InsightsError(this.message);
  @override
  List<Object?> get props => [message];
}
