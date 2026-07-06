import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../providers/gemini_provider.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _controller = TextEditingController();

  // Sends user text to Gemini and updates the parse state
  Future<void> _logExpense() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(expenseParseStateProvider.notifier).state = ExpenseParseLoading();
    try {
      final expense = await ref.read(geminiServiceProvider).parseExpense(text);
      ref.read(expenseParseStateProvider.notifier).state =
          ExpenseParseSuccess(expense);
            ref.read(expenseNotifierProvider.notifier).addExpense(expense);
    } catch (e) {
      ref.read(expenseParseStateProvider.notifier).state =
          ExpenseParseError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final parseState = ref.watch(expenseParseStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Describe your expense',
                hintText: 'e.g. Spent \u20b9250 on auto to office',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _logExpense,
              child: const Text('Log Expense'),
            ),
            const SizedBox(height: 24),
            // Pattern match on all possible parse states
            switch (parseState) {
              ExpenseParseIdle() => const SizedBox.shrink(),
              ExpenseParseLoading() =>
                const CircularProgressIndicator(),
              ExpenseParseSuccess(:final expense) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('\u20b9${expense.amount}',
                        style: Theme.of(context).textTheme.headlineMedium),
                    Chip(label: Text(expense.category)),
                    Text(expense.merchant),
                  ],
                ),
              ExpenseParseError(:final message) =>
                Text('Error: $message',
                    style: const TextStyle(color: Colors.red)),
            },
          ],
        ),
      ),
    );
  }
}