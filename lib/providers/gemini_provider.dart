import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';
import '../models/expense.dart';

// Provides a single instance of GeminiService throughout the app
final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

// Holds the current state of expense parsing (idle, loading, success, error)
final expenseParseStateProvider =
    StateProvider<ExpenseParseState>((ref) => ExpenseParseIdle());