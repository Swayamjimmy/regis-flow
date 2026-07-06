class Expense {
  final String id;
  final double amount;
  final String category;
  final String merchant;
  final DateTime date;
  final String originalText;
  // Split fields
  final bool isSplit;
  final List<String>? friends;
  final double? perPersonAmount;

  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.merchant,
    required this.date,
    required this.originalText,
    this.isSplit = false,
    this.friends,
    this.perPersonAmount,
  });
}

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