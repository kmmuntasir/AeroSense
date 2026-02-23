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
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Appearance ──────────────────────────────────
          _SectionHeader(title: 'Appearance'),
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
                    icon: Icon(Icons.light_mode),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode),
                  ),
                ],
                selected: {controller.isDarkMode},
                onSelectionChanged: (v) => controller.isDarkMode = v.first,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Units ────────────────────────────────────────
          _SectionHeader(title: 'Units'),
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// Settings tile widget for individual settings
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
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
          const SizedBox(height: 16),
          Align(alignment: Alignment.centerRight, child: trailing),
        ],
      ),
    );
  }
}
