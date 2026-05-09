import 'package:equatable/equatable.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

abstract class InsightsEvent extends Equatable {
  const InsightsEvent();
  @override
  List<Object?> get props => [];
}

class GenerateInsights extends InsightsEvent {
  final List<TransactionEntity> transactions;
  const GenerateInsights(this.transactions);
  @override
  List<Object?> get props => [transactions];
}
