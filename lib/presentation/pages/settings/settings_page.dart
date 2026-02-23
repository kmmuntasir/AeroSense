import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aero_sense/core/controllers/settings_controller.dart';
import 'package:aero_sense/core/models/temperature_unit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // ── Appearance ──────────────────────────────────
          _SectionHeader(title: 'Appearance'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle: 'Choose your preferred look',
            trailing: Obx(
              () => SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode, size: 18),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode, size: 18),
                  ),
                ],
                selected: {controller.isDarkMode},
                onSelectionChanged: (v) => controller.isDarkMode = v.first,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.refresh_outlined,
            title: 'Auto-refresh',
            subtitle: 'Update weather automatically',
            trailing: Obx(
              () => Switch(
                value: controller.autoRefreshEnabled,
                onChanged: (value) => controller.autoRefreshEnabled = value,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Units ────────────────────────────────────────
          _SectionHeader(title: 'Units'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.thermostat_outlined,
            title: 'Temperature',
            subtitle: 'Select display unit',
            trailing: Obx(
              () => SegmentedButton<TemperatureUnit>(
                segments: const [
                  ButtonSegment(
                    value: TemperatureUnit.celsius,
                    label: Text('°C'),
                  ),
                  ButtonSegment(
                    value: TemperatureUnit.fahrenheit,
                    label: Text('°F'),
                  ),
                ],
                selected: {controller.temperatureUnit},
                onSelectionChanged: (v) => controller.temperatureUnit = v.first,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Notifications & Services ────────────────────
          _SectionHeader(title: 'Notifications & Services'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Receive weather alerts',
            trailing: Obx(
              () => Switch(
                value: controller.notificationsEnabled,
                onChanged: (value) => controller.notificationsEnabled = value,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.location_on_outlined,
            title: 'Location Services',
            subtitle: 'Use GPS for location',
            trailing: Obx(
              () => Switch(
                value: controller.locationServicesEnabled,
                onChanged: (value) =>
                    controller.locationServicesEnabled = value,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Data Management ──────────────────────────────
          _SectionHeader(title: 'Data Management'),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.delete_outline,
            title: 'Clear Cache',
            subtitle: 'Remove cached weather data',
            onTap: () async {
              await controller.clearCachedData();
              Get.snackbar(
                'Success',
                'Cache cleared',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.restart_alt_outlined,
            title: 'Reset to Defaults',
            subtitle: 'Restore all settings to default',
            onTap: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Reset Settings?'),
                  content: const Text(
                    'This will restore all settings to their default values.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await controller.resetToDefaults();
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Settings reset to defaults',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // ── About ────────────────────────────────────────
          _SectionHeader(title: 'About'),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.info_outline,
            title: 'Version',
            subtitle: 'AeroSense 1.0.0',
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.description_outlined,
            title: 'License',
            subtitle: 'MIT License',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// Section header widget for settings groups
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.primary,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Settings tile widget for toggle switches
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          trailing,
        ],
      ),
    );
  }
}

/// Action tile widget for clickable settings
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Info tile widget for read-only settings
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
