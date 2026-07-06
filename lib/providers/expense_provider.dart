import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';

class ExpenseNotifier extends Notifier<List<Expense>> {
  @override
  List<Expense> build() => [];

  void addExpense(Expense expense) {
    state = [...state, expense];
  }

  double get totalSpent =>
      state.fold(0.0, (sum, e) => sum + e.amount);

  Map<String, double> get categoryBreakdown {
    final map = <String, double>{};
    for (final e in state) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  Map<DateTime, double> get dailySpendingThisWeek {
    final map = <DateTime, double>{};
    final now = DateTime.now();
    for (var i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      map[day] = 0;
    }
    for (final e in state) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      if (map.containsKey(day)) {
        map[day] = (map[day] ?? 0) + e.amount;
      }
    }
    return map;
  }

  double get budgetVelocity {
    final now = DateTime.now();
    final dayOfMonth = now.day;
    if (dayOfMonth == 0) return 0;
    return totalSpent / dayOfMonth;
  }
}

final expenseNotifierProvider =
    NotifierProvider<ExpenseNotifier, List<Expense>>(ExpenseNotifier.new);

final totalSpentProvider = Provider<double>((ref) {
  return ref.watch(expenseNotifierProvider.notifier).totalSpent;
});

final categoryBreakdownProvider = Provider<Map<String, double>>((ref) {
  ref.watch(expenseNotifierProvider);
  return ref.read(expenseNotifierProvider.notifier).categoryBreakdown;
});

final dailySpendingProvider = Provider<Map<DateTime, double>>((ref) {
  ref.watch(expenseNotifierProvider);
  return ref.read(expenseNotifierProvider.notifier).dailySpendingThisWeek;
});

final budgetVelocityProvider = Provider<double>((ref) {
  ref.watch(expenseNotifierProvider);
  return ref.read(expenseNotifierProvider.notifier).budgetVelocity;
});