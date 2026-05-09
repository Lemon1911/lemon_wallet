import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/services/ai_advisor_service.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

// Events
abstract class AiChatEvent extends Equatable {
  const AiChatEvent();
  @override
  List<Object?> get props => [];
}

class SendMessage extends AiChatEvent {
  final String message;
  final List<TransactionEntity> transactions;
  const SendMessage(this.message, this.transactions);
  @override
  List<Object?> get props => [message, transactions];
}

class ClearChat extends AiChatEvent {}

// States
abstract class AiChatState extends Equatable {
  const AiChatState();
  @override
  List<Object?> get props => [];
}

class AiChatInitial extends AiChatState {}

class AiChatLoading extends AiChatState {
  final List<ChatMessage> messages;
  const AiChatLoading(this.messages);
  @override
  List<Object?> get props => [messages];
}

class AiChatLoaded extends AiChatState {
  final List<ChatMessage> messages;
  final List<Content> history;
  const AiChatLoaded(this.messages, this.history);
  @override
  List<Object?> get props => [messages, history];
}

class AiChatError extends AiChatState {
  final String message;
  final List<ChatMessage> messages;
  const AiChatError(this.message, this.messages);
  @override
  List<Object?> get props => [message, messages];
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

// Bloc
class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  final AiAdvisorService _aiAdvisorService;

  AiChatBloc({required AiAdvisorService aiAdvisorService})
      : _aiAdvisorService = aiAdvisorService,
        super(AiChatInitial()) {
    on<SendMessage>(_onSendMessage);
    on<ClearChat>(_onClearChat);
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<AiChatState> emit) async {
    List<ChatMessage> currentMessages = [];
    List<Content> currentHistory = [];

    if (state is AiChatLoaded) {
      currentMessages = List.from((state as AiChatLoaded).messages);
      currentHistory = List.from((state as AiChatLoaded).history);
    } else if (state is AiChatError) {
      currentMessages = List.from((state as AiChatError).messages);
    }

    final userMessage = ChatMessage(text: event.message, isUser: true);
    currentMessages.add(userMessage);
    
    emit(AiChatLoading(currentMessages));

    final response = await _aiAdvisorService.chat(
      event.message,
      event.transactions,
      history: currentHistory.isEmpty ? null : currentHistory,
    );

    final aiMessage = ChatMessage(text: response, isUser: false);
    currentMessages.add(aiMessage);

    // Update history for Gemini
    if (currentHistory.isEmpty) {
      // Add system instruction + initial model response if first time
      // This is handled in the service for the first message, 
      // but we need to track it here for subsequent calls.
    }
    currentHistory.add(Content.text(event.message));
    currentHistory.add(Content.model([TextPart(response)]));

    emit(AiChatLoaded(currentMessages, currentHistory));
  }

  void _onClearChat(ClearChat event, Emitter<AiChatState> emit) {
    emit(AiChatInitial());
  }
}
