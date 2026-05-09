import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

class AiAdvisorService {
  final GenerativeModel _model;

  AiAdvisorService(String apiKey) 
      : _model = GenerativeModel(
          model: 'gemini-2.0-flash', 
          apiKey: apiKey,
        );

  Future<List<String>> getFinancialInsights(List<TransactionEntity> transactions) async {
    if (transactions.isEmpty) return ['Add some transactions to get personalized AI insights!'];

    final transactionData = transactions.map((t) => {
      'type': t.type.name,
      'amount': t.amount,
      'date': t.transactionDate.toIso8601String(),
      'note': t.note,
    }).toList();

    final prompt = '''
    You are a Smart Personal CFO. Analyze the following financial transactions and provide 3-4 concise, actionable, and encouraging financial tips or insights.
    Format your response as a JSON array of strings.
    
    Transactions:
    ${jsonEncode(transactionData)}
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      final text = response.text;
      if (text == null) return ['Unable to generate insights at the moment.'];

      // Clean up the response if it contains markdown code blocks
      final cleanedText = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> jsonResponse = jsonDecode(cleanedText);
      return jsonResponse.map((e) => e.toString()).toList();
    } catch (e) {
      debugPrint('AI Insight Error: $e');
      if (e.toString().contains('quota')) {
        return ['The AI is currently busy. Please try again in a minute! 🍋'];
      }
      return ['Keep tracking your expenses to build a healthier financial future!'];
    }
  }

  Future<List<Map<String, dynamic>>> suggestSmartGoals(List<TransactionEntity> transactions) async {
    if (transactions.isEmpty) return [];

    final transactionData = transactions.map((t) => {
      'type': t.type.name,
      'amount': t.amount,
      'date': t.transactionDate.toIso8601String(),
    }).toList();

    final prompt = '''
    You are a Smart Personal CFO. Analyze the following financial transactions and suggest 3 "Smart Goals" for the user.
    Each goal should have:
    - title: Short and catchy (e.g., "Coffee Reduction", "Emergency Fund Starter")
    - description: Actionable advice
    - targetAmount: A recommended numeric amount to save/stay under
    - type: Either "savings" or "budget"
    
    Format your response as a JSON array of objects.
    
    Transactions:
    ${jsonEncode(transactionData)}
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      final text = response.text;
      if (text == null) return [];

      final cleanedText = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> jsonResponse = jsonDecode(cleanedText);
      return jsonResponse.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('AI Goal Suggestion Error: $e');
      if (e.toString().contains('quota')) {
        return [{
          'title': 'AI is resting',
          'description': 'The Smart CFO is busy right now. Try again in a minute! 🍋',
          'targetAmount': 0,
          'type': 'savings'
        }];
      }
      return [];
    }
  }

  Future<String> chat(String message, List<TransactionEntity> transactions, {List<Content>? history}) async {
    final transactionData = transactions.map((t) => {
      'type': t.type.name,
      'amount': t.amount,
      'date': t.transactionDate.toIso8601String(),
      'note': t.note,
    }).toList();

    final systemInstruction = '''
    You are Lemon, a witty and helpful Personal CFO AI. 
    You have access to the user's transaction history below.
    Help the user understand their spending, suggest savings, or answer any financial questions.
    Be concise, encouraging, and use emojis occasionally 🍋.
    
    User Transactions:
    ${jsonEncode(transactionData)}
    ''';

    try {
      final chatSession = _model.startChat(history: history ?? [
        Content.text(systemInstruction),
        Content.model([TextPart('Understood! I am ready to help you manage your money as Lemon, your Personal CFO. How can I assist you today? 🍋')])
      ]);
      
      final response = await chatSession.sendMessage(Content.text(message));
      return response.text ?? 'I am sorry, I could not process that request.';
    } catch (e) {
      debugPrint('AI Chat Error: $e');
      return 'Oops! I hit a bit of a snag. Can you try asking that again? 🍋';
    }
  }
}
