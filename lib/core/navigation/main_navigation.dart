import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../features/dead_minutes/presentation/pages/dead_minutes_page.dart';
import '../../features/home/home_screen.dart';
import '../../features/plan/plan_screen.dart';
import '../../features/settings/settings_screen.dart';

/// Main navigation scaffold with bottom navigation bar.
///
/// Calm Operational UI: Flat, minimal navigation.
/// - Motion: 200ms easeInOut (subtle transition)
/// - No heavy splashes or scaling
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Cache screens to prevent rebuilding
  final List<Widget> _screens = const [
    HomeScreen(),
    PlanScreen(),
    DeadMinutesPage(),
    SettingsScreen(),
  ];

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: _currentIndex, children: _screens),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: _onTabSelected,
      elevation: 0,
      backgroundColor: AppColors.backgroundPrimary,
      indicatorColor: Colors.transparent,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 72,
      // Standardize motion
      animationDuration: AppMotion.durationShort,
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.today_outlined, color: AppColors.textSecondary),
          selectedIcon: Icon(Icons.today, color: AppColors.accentPrimary),
          label: 'Today',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.calendar_month_outlined,
            color: AppColors.textSecondary,
          ),
          selectedIcon: Icon(
            Icons.calendar_month,
            color: AppColors.accentPrimary,
          ),
          label: 'Plan',
        ),
        NavigationDestination(
          icon: Icon(Icons.timer_outlined, color: AppColors.textSecondary),
          selectedIcon: Icon(Icons.timer, color: AppColors.accentPrimary),
          label: 'DeadMinutes',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined, color: AppColors.textSecondary),
          selectedIcon: Icon(Icons.settings, color: AppColors.accentPrimary),
          label: 'Settings',
        ),
      ],
    ),
  );
}
