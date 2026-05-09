import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/services/ai_advisor_service.dart';
import 'insights_event.dart';
import 'insights_state.dart';

class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final AiAdvisorService _aiAdvisorService;

  InsightsBloc({required AiAdvisorService aiAdvisorService})
      : _aiAdvisorService = aiAdvisorService,
        super(InsightsInitial()) {
    on<GenerateInsights>(_onGenerateInsights);
  }

  Future<void> _onGenerateInsights(
    GenerateInsights event,
    Emitter<InsightsState> emit,
  ) async {
    emit(InsightsLoading());
    try {
      final results = await Future.wait([
        _aiAdvisorService.getFinancialInsights(event.transactions),
        _aiAdvisorService.suggestSmartGoals(event.transactions),
      ]);
      
      final insights = results[0] as List<String>;
      final goals = results[1] as List<Map<String, dynamic>>;
      
      emit(InsightsLoaded(insights, suggestedGoals: goals));
    } catch (e) {
      emit(InsightsError(e.toString()));
    }
  }
}
