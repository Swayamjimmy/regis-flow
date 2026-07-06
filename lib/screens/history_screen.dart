import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

// Available categories for filtering
const _categories = ['All', 'Food', 'Transport', 'Shopping', 'Entertainment', 'Health', 'Other'];

// Map each category to a recognizable icon
const _categoryIcons = {
  'Food': Icons.restaurant,
  'Transport': Icons.directions_car,
  'Shopping': Icons.shopping_bag,
  'Entertainment': Icons.movie,
  'Health': Icons.health_and_safety,
  'Other': Icons.category,
};

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  // Tracks which category filter chip is selected
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expenseNotifierProvider);
    // Filter expenses based on the selected category chip
    final filtered = _selectedCategory == 'All'
        ? expenses
        : expenses.where((e) => e.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          // Horizontal scrollable row of filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: _categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: _selectedCategory == cat,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          // Expense list showing each transaction as a ListTile
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final expense = filtered[index];
                return ListTile(
                  leading: Icon(
                      _categoryIcons[expense.category] ?? Icons.category),
                  title: Text(expense.merchant),
                  subtitle: Text(expense.originalText),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\u20b9${expense.amount.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}