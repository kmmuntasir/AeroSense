import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/settings_controller.dart';
import '../../../core/models/temperature_unit.dart';
import '../../../core/models/wind_speed_unit.dart';
import '../../../core/models/precipitation_unit.dart';

const _primaryAccent = Color(0xFF2B3BEE);
const _pageBg = Color(0xFFF2F2F7);
const _cardBg = Colors.white;
const _sectionHeader = Color(0xFF64748B);
const _primaryText = Color(0xFF0F172A);
const _dividerColor = Color(0xFFF1F5F9);
const _toggleOff = Color(0xFFCBD5E1);
const _logoutRed = Color(0xFFDC2626);

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            const _SettingsHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionGroup(
                      title: 'UNITS',
                      children: [
                        _TemperatureRow(controller: controller),
                        _sectionDivider(),
                        _UnitRow(
                          label: 'Wind Speed',
                          value: Obx(
                            () =>
                                Text(_windSpeedLabel(controller.windSpeedUnit)),
                          ),
                          onTap: () => _showWindSpeedSheet(controller),
                        ),
                        _sectionDivider(),
                        _UnitRow(
                          label: 'Precipitation',
                          value: Obx(
                            () => Text(
                              _precipLabel(controller.precipitationUnit),
                            ),
                          ),
                          onTap: () => _showPrecipSheet(controller),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SectionGroup(
                      title: 'APPEARANCE',
                      children: [
                        Obx(
                          () => _ToggleRow(
                            label: 'Dark Mode',
                            icon: Icons.dark_mode_outlined,
                            value: controller.isDarkMode,
                            enabled: !controller.useSystemTheme,
                            onChanged: (v) => controller.isDarkMode = v,
                          ),
                        ),
                        _sectionDivider(),
                        Obx(
                          () => _ToggleRow(
                            label: 'Use System Setting',
                            icon: Icons.phone_android_outlined,
                            value: controller.useSystemTheme,
                            onChanged: (v) => controller.useSystemTheme = v,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SectionGroup(
                      title: 'NOTIFICATIONS',
                      children: [
                        Obx(
                          () => _ToggleRow(
                            label: 'Severe Weather',
                            icon: Icons.warning_amber_outlined,
                            value: controller.severeWeatherAlerts,
                            onChanged: (v) =>
                                controller.severeWeatherAlerts = v,
                          ),
                        ),
                        _sectionDivider(),
                        Obx(
                          () => _ToggleRow(
                            label: 'Morning Summary',
                            icon: Icons.wb_sunny_outlined,
                            value: controller.morningNotifications,
                            onChanged: (v) =>
                                controller.morningNotifications = v,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SectionGroup(
                      title: 'ABOUT & SUPPORT',
                      children: [
                        _LinkRow(
                          label: 'Help Center',
                          icon: Icons.help_outline,
                          onTap: () {},
                        ),
                        _sectionDivider(),
                        _LinkRow(
                          label: 'Privacy Policy',
                          icon: Icons.privacy_tip_outlined,
                          onTap: () {},
                        ),
                        _sectionDivider(),
                        const _VersionRow(version: '1.0.0'),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _LogoutButton(controller: controller),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _SettingsBottomNav(),
    );
  }

  Widget _sectionDivider() => const Divider(
    height: 1,
    thickness: 1,
    color: _dividerColor,
    indent: 16,
    endIndent: 16,
  );

  String _windSpeedLabel(WindSpeedUnit unit) {
    switch (unit) {
      case WindSpeedUnit.kmh:
        return 'km/h';
      case WindSpeedUnit.mph:
        return 'mph';
      case WindSpeedUnit.ms:
        return 'm/s';
    }
  }

  String _precipLabel(PrecipitationUnit unit) {
    switch (unit) {
      case PrecipitationUnit.mm:
        return 'mm';
      case PrecipitationUnit.inch:
        return 'inch';
    }
  }

  void _showWindSpeedSheet(SettingsController controller) {
    Get.bottomSheet(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _toggleOff,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            for (final unit in WindSpeedUnit.values)
              Obx(
                () => ListTile(
                  title: Text(
                    _windSpeedLabelFor(unit),
                    style: const TextStyle(
                      color: _primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: controller.windSpeedUnit == unit
                      ? const Icon(Icons.check, color: _primaryAccent)
                      : null,
                  onTap: () {
                    controller.windSpeedUnit = unit;
                    Get.back();
                  },
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  void _showPrecipSheet(SettingsController controller) {
    Get.bottomSheet(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _toggleOff,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            for (final unit in PrecipitationUnit.values)
              Obx(
                () => ListTile(
                  title: Text(
                    _precipLabelFor(unit),
                    style: const TextStyle(
                      color: _primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: controller.precipitationUnit == unit
                      ? const Icon(Icons.check, color: _primaryAccent)
                      : null,
                  onTap: () {
                    controller.precipitationUnit = unit;
                    Get.back();
                  },
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  String _windSpeedLabelFor(WindSpeedUnit unit) {
    switch (unit) {
      case WindSpeedUnit.kmh:
        return 'km/h';
      case WindSpeedUnit.mph:
        return 'mph';
      case WindSpeedUnit.ms:
        return 'm/s';
    }
  }

  String _precipLabelFor(PrecipitationUnit unit) {
    switch (unit) {
      case PrecipitationUnit.mm:
        return 'mm';
      case PrecipitationUnit.inch:
        return 'inch';
    }
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _pageBg,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: _primaryText,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section group card ───────────────────────────────────────────────────────

class _SectionGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _sectionHeader,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

// ─── Temperature segmented row ───────────────────────────────────────────────

class _TemperatureRow extends StatelessWidget {
  final SettingsController controller;

  const _TemperatureRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(
            Icons.thermostat_outlined,
            size: 20,
            color: _sectionHeader,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Temperature',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _primaryText,
              ),
            ),
          ),
          Obx(
            () => _SegmentedControl(
              options: const ['°C', '°F'],
              selected: controller.temperatureUnit == TemperatureUnit.celsius
                  ? 0
                  : 1,
              onSelected: (i) => controller.temperatureUnit = i == 0
                  ? TemperatureUnit.celsius
                  : TemperatureUnit.fahrenheit,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelected;

  const _SegmentedControl({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEF0F6),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (i) {
          final isActive = i == selected;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? _primaryAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                options[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : _sectionHeader,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Unit row (navigates to bottom sheet) ───────────────────────────────────

class _UnitRow extends StatelessWidget {
  final String label;
  final Widget value;
  final VoidCallback onTap;

  const _UnitRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(
              Icons.straighten_outlined,
              size: 20,
              color: _sectionHeader,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _primaryText,
                ),
              ),
            ),
            DefaultTextStyle(
              style: const TextStyle(fontSize: 14, color: _sectionHeader),
              child: value,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: _sectionHeader),
          ],
        ),
      ),
    );
  }
}

// ─── Toggle row ──────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? _primaryText : _toggleOff;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: enabled ? _sectionHeader : _toggleOff),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: effectiveColor,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: Colors.white,
            activeTrackColor: _primaryAccent,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: _toggleOff,
          ),
        ],
      ),
    );
  }
}

// ─── Link row ────────────────────────────────────────────────────────────────

class _LinkRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _LinkRow({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: _sectionHeader),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _primaryText,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: _sectionHeader),
          ],
        ),
      ),
    );
  }
}

// ─── Version row ─────────────────────────────────────────────────────────────

class _VersionRow extends StatelessWidget {
  final String version;

  const _VersionRow({required this.version});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20, color: _sectionHeader),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'App Version',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _primaryText,
              ),
            ),
          ),
          Text(
            version,
            style: const TextStyle(fontSize: 14, color: _sectionHeader),
          ),
        ],
      ),
    );
  }
}

// ─── Logout button ───────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  final SettingsController controller;

  const _LogoutButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => _confirmLogout(context),
        style: TextButton.styleFrom(
          backgroundColor: _cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _logoutRed,
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Clear data and return to onboarding?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await controller.clearAllData();
              Get.offAllNamed('/onboarding');
            },
            child: const Text('Log Out', style: TextStyle(color: _logoutRed)),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom navigation bar ───────────────────────────────────────────────────

class _SettingsBottomNav extends StatelessWidget {
  const _SettingsBottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3,
      selectedItemColor: _primaryAccent,
      unselectedItemColor: _sectionHeader,
      backgroundColor: _cardBg,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      onTap: (index) {
        switch (index) {
          case 0:
            Get.offNamed('/dashboard');
          case 1:
            Get.offNamed('/search');
          case 2:
            // Alerts — not yet implemented
            break;
          case 3:
            // Already on settings
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          activeIcon: Icon(Icons.notifications),
          label: 'Alerts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
