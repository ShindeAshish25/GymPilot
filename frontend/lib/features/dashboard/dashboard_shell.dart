import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/floating_nav_bar.dart';
import '../../core/widgets/app_header.dart';
import '../../core/constants/app_colors.dart';

class DashboardShell extends StatelessWidget {
  final Widget child;

  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(notificationCount: 3),
      body: child
          .animate(key: ValueKey(currentIndex))
          .fadeIn(duration: 300.ms)
          .slide(begin: const Offset(0, 0.03), end: const Offset(0, 0)),
      bottomNavigationBar: FloatingNavBar(
        currentIndex: currentIndex,
        onTap: (int idx) => _onItemTapped(idx, context),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/members') || location.startsWith('/overdue') || location.startsWith('/all-members')) return 1;
    if (location.startsWith('/trainers')) return 2;
    if (location.startsWith('/expenses')) return 3;
    if (location.startsWith('/reports')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/members');
        break;
      case 2:
        context.go('/trainers');
        break;
      case 3:
        context.go('/expenses');
        break;
      case 4:
        context.go('/reports');
        break;
    }
  }
}
