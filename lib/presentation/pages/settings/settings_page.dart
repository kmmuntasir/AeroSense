import 'package:aero_sense/core/constants/app_constants.dart';
import 'package:aero_sense/core/controllers/settings_controller.dart';
import 'package:aero_sense/core/models/temperature_unit.dart';
import 'package:aero_sense/core/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainer,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: cs.surfaceContainer,
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // ── Units ─────────────────────────────────────
            const _SectionLabel(label: 'UNITS'),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _TemperatureRow(controller: controller),
                const _CardDivider(),
                _NavigationRow(
                  icon: Icons.air,
                  iconColor: AppTheme.iconBlue,
                  label: 'Wind Speed',
                  value: 'km/h',
                  onTap: () {},
                ),
                const _CardDivider(),
                _NavigationRow(
                  icon: Icons.water_drop_outlined,
                  iconColor: AppTheme.iconLightBlue,
                  label: 'Precipitation',
                  value: 'mm',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Appearance ────────────────────────────────
            const _SectionLabel(label: 'APPEARANCE'),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                Obx(
                  () => _SwitchRow(
                    icon: Icons.nightlight_round,
                    iconColor: AppTheme.iconIndigo,
                    label: 'Dark Mode',
                    value: controller.isDarkMode,
                    onChanged: (v) => controller.isDarkMode = v,
                  ),
                ),
                const _CardDivider(),
                Obx(
                  () => _SwitchRow(
                    icon: Icons.settings_display_outlined,
                    iconColor: AppTheme.primaryColor,
                    label: 'Use System Setting',
                    value: controller.locationServicesEnabled,
                    onChanged: (v) => controller.locationServicesEnabled = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Notifications ─────────────────────────────
            const _SectionLabel(label: 'NOTIFICATIONS'),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                Obx(
                  () => _SwitchRow(
                    icon: Icons.warning_amber_rounded,
                    iconColor: AppTheme.iconRed,
                    label: 'Severe Weather',
                    value: controller.notificationsEnabled,
                    onChanged: (v) => controller.notificationsEnabled = v,
                  ),
                ),
                const _CardDivider(),
                Obx(
                  () => _SwitchRow(
                    icon: Icons.wb_sunny_outlined,
                    iconColor: AppTheme.iconOrange,
                    label: 'Morning Summary',
                    value: controller.flightWarningsEnabled,
                    onChanged: (v) => controller.flightWarningsEnabled = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── About & Support ───────────────────────────
            const _SectionLabel(label: 'ABOUT & SUPPORT'),
            const SizedBox(height: 8),
            _SettingsCard(
              children: [
                _NavigationRow(
                  icon: Icons.help_outline_rounded,
                  iconColor: AppTheme.iconTeal,
                  label: 'Help Center',
                  onTap: () {},
                ),
                const _CardDivider(),
                _NavigationRow(
                  icon: Icons.lock_outline_rounded,
                  iconColor: AppTheme.iconPurple,
                  label: 'Privacy Policy',
                  onTap: () {},
                ),
                const _CardDivider(),
                const _InfoRow(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppTheme.iconGrey,
                  label: 'App Version',
                  value: 'v2.4.1',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Log Out ───────────────────────────────────
            _SettingsCard(
              children: [
                InkWell(
                  onTap: () => _showLogOutDialog(context),
                  borderRadius: BorderRadius.circular(
                    AppConstants.settingsCardRadius,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Log Out',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showLogOutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Log Out',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Settings Card ─────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppConstants.settingsCardRadius),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

// ── Divider ───────────────────────────────────────────────────────────────────

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 0,
      color: Theme.of(context).colorScheme.outlineVariant.withAlpha(80),
    );
  }
}

// ── Icon Container ────────────────────────────────────────────────────────────

class _IconContainer extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconContainer({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppConstants.iconContainerRadius),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

// ── Switch Row ────────────────────────────────────────────────────────────────

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _IconContainer(icon: icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: AppConstants.settingsRowFontSize,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: cs.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

// ── Navigation Row ────────────────────────────────────────────────────────────

class _NavigationRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _NavigationRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _IconContainer(icon: icon, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: AppConstants.settingsRowFontSize,
                ),
              ),
            ),
            if (value != null) ...[
              Text(value ?? '', style: tt.bodyMedium),
              const SizedBox(width: 4),
            ],
            Icon(Icons.chevron_right, size: 20, color: tt.bodyMedium?.color),
          ],
        ),
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _IconContainer(icon: icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: AppConstants.settingsRowFontSize,
              ),
            ),
          ),
          Text(
            value,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: AppConstants.settingsValueFontSize,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Temperature Row ───────────────────────────────────────────────────────────

class _TemperatureRow extends StatelessWidget {
  final SettingsController controller;

  const _TemperatureRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const _IconContainer(
            icon: Icons.thermostat_outlined,
            color: AppTheme.iconBlue,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Temperature',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: AppConstants.settingsRowFontSize,
              ),
            ),
          ),
          _TempToggle(controller: controller),
        ],
      ),
    );
  }
}

// ── Temp Toggle ───────────────────────────────────────────────────────────────

class _TempToggle extends StatelessWidget {
  final SettingsController controller;

  const _TempToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.tempToggleRadius),
      ),
      child: Obx(() {
        final isCelsius = controller.temperatureUnit == TemperatureUnit.celsius;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TempOption(
              label: '°C',
              selected: isCelsius,
              selectedColor: cs.primary,
              unselectedColor: cs.onSurfaceVariant,
              onTap: () => controller.temperatureUnit = TemperatureUnit.celsius,
            ),
            _TempOption(
              label: '°F',
              selected: !isCelsius,
              selectedColor: cs.primary,
              unselectedColor: cs.onSurfaceVariant,
              onTap: () =>
                  controller.temperatureUnit = TemperatureUnit.fahrenheit,
            ),
          ],
        );
      }),
    );
  }
}

class _TempOption extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  const _TempOption({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? cs.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.tempOptionRadius),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
            color: selected ? selectedColor : unselectedColor,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: AppConstants.settingsValueFontSize,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
