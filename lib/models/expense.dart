import 'package:flutter/foundation.dart';

// Data class representing a single parsed expense
class Expense {
  final String id;
  final double amount;
  final String category;
  final String merchant;
  final DateTime date;
  final String originalText;

  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.merchant,
    required this.date,
    required this.originalText,
  });
}

// Sealed class representing all possible states of expense parsing
sealed class ExpenseParseState {}

class ExpenseParseIdle extends ExpenseParseState {}

class ExpenseParseLoading extends ExpenseParseState {}

class ExpenseParseSuccess extends ExpenseParseState {
  final Expense expense;
  ExpenseParseSuccess(this.expense);
}

class ExpenseParseError extends ExpenseParseState {
  final String message;
  ExpenseParseError(this.message);
}