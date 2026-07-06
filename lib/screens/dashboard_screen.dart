import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';

const _monthlyBudget = 30000.0;

const _categoryColors = {
  'Food': Colors.orange,
  'Transport': Colors.blue,
  'Shopping': Colors.purple,
  'Entertainment': Colors.pink,
  'Health': Colors.green,
  'Other': Colors.grey,
};

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final velocity = ref.watch(budgetVelocityProvider);
    final totalSpent = ref.watch(totalSpentProvider);
    final categoryBreakdown = ref.watch(categoryBreakdownProvider);
    final dailySpending = ref.watch(dailySpendingProvider);

    Color velocityColor;
    if (velocity < 1000) {
      velocityColor = Colors.green;
    } else if (velocity <= 1500) {
      velocityColor = Colors.yellow;
    } else {
      velocityColor = Colors.red;
    }

    // Build pie chart sections from category breakdown
    final pieChartSections = categoryBreakdown.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: entry.key,
        color: _categoryColors[entry.key] ?? Colors.grey,
        radius: 80,
      );
    }).toList();

    // Build bar chart groups for daily spending
    final dailyEntries = dailySpending.entries.toList();
    final barGroups = List.generate(dailyEntries.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: dailyEntries[i].value,
            color: Colors.tealAccent,
            width: 16,
          ),
        ],
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budget velocity card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Budget Velocity',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      '\u20b9${velocity.toStringAsFixed(0)}/day',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: velocityColor),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (totalSpent / _monthlyBudget).clamp(0.0, 1.0),
                      color: velocityColor,
                      backgroundColor: Colors.grey.shade800,
                    ),
                    const SizedBox(height: 4),
                    Text(
                        '\u20b9${totalSpent.toStringAsFixed(0)} of \u20b9${_monthlyBudget.toStringAsFixed(0)} monthly budget'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Pie chart for category breakdown
            Text('Spending by Category',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: pieChartSections.isEmpty
                  ? const Center(child: Text('No expenses yet'))
                  : PieChart(PieChartData(sections: pieChartSections)),
            ),
            const SizedBox(height: 24),
            // Bar chart for daily spending
            Text('Daily Spending (Last 7 Days)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}