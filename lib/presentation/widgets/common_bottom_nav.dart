import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shared bottom navigation bar used on all top-level pages.
///
/// [selectedIndex]:
///  0 = Dashboard, 1 = Locations, 2 = Alerts, 3 = Settings
///
/// [onLocalTap]: optional override to intercept taps before routing.
/// Return `true` to consume the tap (no routing), `false` to let the
/// default routing run. Use this on the Dashboard to handle the
/// Dashboard/Locations tab switch with `setState`.
class CommonBottomNav extends StatelessWidget {
  final int selectedIndex;

  /// Return `true` to consume the tap locally (skip routing).
  final bool Function(int index)? onLocalTap;

  const CommonBottomNav({
    super.key,
    required this.selectedIndex,
    this.onLocalTap,
  });

  void _onTap(int index) {
    if (index == selectedIndex) return;
    if (onLocalTap != null && onLocalTap!(index)) return;
    switch (index) {
      case 0:
      case 1:
        Get.offAllNamed('/dashboard');
      case 2:
        Get.offNamed('/weather-alerts');
      case 3:
        Get.offNamed('/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Locations',
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
    );
  }
}
