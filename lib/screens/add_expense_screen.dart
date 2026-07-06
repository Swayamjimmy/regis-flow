import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
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
  final _friendsController = TextEditingController();
  bool _splitEnabled = false;

  Future<void> _logExpense() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(expenseParseStateProvider.notifier).state = ExpenseParseLoading();
    try {
      final parsed = await ref.read(geminiServiceProvider).parseExpense(text);
      List<String>? friends;
      double? perPerson;
      if (_splitEnabled && _friendsController.text.trim().isNotEmpty) {
        friends = _friendsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        final totalPeople = friends.length + 1;
        perPerson = parsed.amount / totalPeople;
      }
      final expense = Expense(
        id: parsed.id,
        amount: parsed.amount,
        category: parsed.category,
        merchant: parsed.merchant,
        date: parsed.date,
        originalText: parsed.originalText,
        isSplit: _splitEnabled && friends != null,
        friends: friends,
        perPersonAmount: perPerson,
      );
      ref.read(expenseParseStateProvider.notifier).state =
          ExpenseParseSuccess(expense);
      ref.read(expenseNotifierProvider.notifier).addExpense(expense);
    } catch (e) {
      ref.read(expenseParseStateProvider.notifier).state =
          ExpenseParseError(e.toString());
    }
  }

  void _shareSplit(Expense expense) {
    final msg =
        'SpendSense Split: \u20b9${expense.amount.toStringAsFixed(0)} ${expense.merchant} '
        '- Your share: \u20b9${expense.perPersonAmount!.toStringAsFixed(0)}. Pay via UPI!';
    Share.share(msg);
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
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Split with friends'),
                const Spacer(),
                Switch(
                  value: _splitEnabled,
                  onChanged: (v) => setState(() => _splitEnabled = v),
                ),
              ],
            ),
            if (_splitEnabled) ...
              [
                TextField(
                  controller: _friendsController,
                  decoration: const InputDecoration(
                    labelText: 'Friend names (comma-separated)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _logExpense,
              child: const Text('Log Expense'),
            ),
            const SizedBox(height: 24),
            switch (parseState) {
              ExpenseParseIdle() => const SizedBox.shrink(),
              ExpenseParseLoading() => const CircularProgressIndicator(),
              ExpenseParseSuccess(:final expense) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('\u20b9${expense.amount}',
                        style: Theme.of(context).textTheme.headlineMedium),
                    Chip(label: Text(expense.category)),
                    Text(expense.merchant),
                    if (expense.isSplit && expense.perPersonAmount != null) ...
                      [
                        const SizedBox(height: 8),
                        Text(
                            'Per person: \u20b9${expense.perPersonAmount!.toStringAsFixed(0)}'),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _shareSplit(expense),
                          icon: const Icon(Icons.share),
                          label: const Text('Share Split'),
                        ),
                      ],
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