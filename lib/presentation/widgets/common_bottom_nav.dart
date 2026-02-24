import 'package:aero_sense/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shared bottom navigation bar used on all top-level pages.
///
/// [selectedIndex]:
///  0 = Dashboard, 1 = Search, 2 = Alerts, 3 = Settings
class CommonBottomNav extends StatelessWidget {
  final int selectedIndex;

  const CommonBottomNav({
    super.key,
    required this.selectedIndex,
  });

  void _onTap(int index) {
    if (index == selectedIndex) return;
    switch (index) {
      case 0:
        Get.offAllNamed('/dashboard');
      case 1:
        Get.offNamed('/search');
      case 2:
        Get.offNamed('/weather-alerts');
      case 3:
        Get.offNamed('/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const selectedColor = AppColors.getStartedButton;
    const unselectedColor = AppColors.textSecondary;

    return Theme(
      data: theme.copyWith(
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: selectedColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              );
            }
            return const TextStyle(
              color: unselectedColor,
              fontWeight: FontWeight.normal,
              fontSize: 13,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: selectedColor, size: 28);
            }
            return const IconThemeData(color: unselectedColor, size: 28);
          }),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: _onTap,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications),
              label: 'Alerts',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
