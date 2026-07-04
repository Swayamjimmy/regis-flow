import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import '../models/expense.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.5-flash',
      systemInstruction: Content.system(
        'You are an expense parser for Indian users. '
        'Extract amount (number), category (Food/Transport/Shopping/Entertainment/Health/Other), '
        'merchant (string), and date (ISO8601, default today if not mentioned) '
        'from the user text. Return ONLY valid JSON: '
        '{"amount": 0.0, "category": "", "merchant": "", "date": ""}',
      ),
    );
  }

  // Sends natural language text to Gemini and returns a structured Expense
  Future<Expense> parseExpense(String text) async {
    final response = await _model.generateContent([Content.text(text)]);
    final json = jsonDecode(response.text ?? '{}') as Map<String, dynamic>;
    return Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      merchant: json['merchant'] as String,
      date: DateTime.parse(json['date'] as String),
      originalText: text,
    );
  }
}