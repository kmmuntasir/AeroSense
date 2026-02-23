import 'package:aero_sense/core/controllers/settings_controller.dart';
import 'package:aero_sense/core/models/temperature_unit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
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
                  iconColor: const Color(0xFF5B8DEF),
                  label: 'Wind Speed',
                  value: 'km/h',
                  onTap: () {},
                ),
                const _CardDivider(),
                _NavigationRow(
                  icon: Icons.water_drop_outlined,
                  iconColor: const Color(0xFF4FC3F7),
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
                    iconColor: const Color(0xFF7986CB),
                    label: 'Dark Mode',
                    value: controller.isDarkMode,
                    onChanged: (v) => controller.isDarkMode = v,
                  ),
                ),
                const _CardDivider(),
                Obx(
                  () => _SwitchRow(
                    icon: Icons.settings_display_outlined,
                    iconColor: const Color(0xFF42A5F5),
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
                    iconColor: const Color(0xFFEF5350),
                    label: 'Severe Weather',
                    value: controller.notificationsEnabled,
                    onChanged: (v) => controller.notificationsEnabled = v,
                  ),
                ),
                const _CardDivider(),
                Obx(
                  () => _SwitchRow(
                    icon: Icons.wb_sunny_outlined,
                    iconColor: const Color(0xFFFFA726),
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
                  iconColor: const Color(0xFF26A69A),
                  label: 'Help Center',
                  onTap: () {},
                ),
                const _CardDivider(),
                _NavigationRow(
                  icon: Icons.lock_outline_rounded,
                  iconColor: const Color(0xFFAB47BC),
                  label: 'Privacy Policy',
                  onTap: () {},
                ),
                const _CardDivider(),
                const _InfoRow(
                  icon: Icons.info_outline_rounded,
                  iconColor: Color(0xFF78909C),
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
                  borderRadius: BorderRadius.circular(14),
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
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: textTheme.bodyMedium?.copyWith(
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
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
        borderRadius: BorderRadius.circular(8),
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
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Theme.of(context).colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
            if (value != null) ...[
              Text(value ?? '', style: textTheme.bodyMedium),
              const SizedBox(width: 4),
            ],
            Icon(
              Icons.chevron_right,
              size: 20,
              color: textTheme.bodyMedium?.color,
            ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _IconContainer(icon: icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const _IconContainer(
            icon: Icons.thermostat_outlined,
            color: Color(0xFF5B8DEF),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Temperature',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: 15,
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
    final colorScheme = Theme.of(context).colorScheme;
    final selectedColor = colorScheme.primary;
    final unselectedColor = colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Obx(() {
        final isCelsius = controller.temperatureUnit == TemperatureUnit.celsius;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TempOption(
              label: '°C',
              selected: isCelsius,
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
              onTap: () => controller.temperatureUnit = TemperatureUnit.celsius,
            ),
            _TempOption(
              label: '°F',
              selected: !isCelsius,
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
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
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
            color: selected ? selectedColor : unselectedColor,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
