import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/history_screen.dart';

// Top-level router configuration with ShellRoute for persistent nav
final router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/add',
          builder: (context, state) => const AddExpenseScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
      ],
    ),
  ],
);

// Shell widget that renders the BottomNavigationBar around child screens
class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Read the current route URI to highlight the correct tab
    final location = GoRouterState.of(context).uri.toString();
    int currentIndex = 0;
    if (location.startsWith('/add')) currentIndex = 1;
    if (location.startsWith('/history')) currentIndex = 2;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go('/'); break;
            case 1: context.go('/add'); break;
            case 2: context.go('/history'); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.add_circle), label: 'Add'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}