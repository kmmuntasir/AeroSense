import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aero_sense/core/controllers/weather_controller.dart';

class AirQualityCard extends StatelessWidget {
  const AirQualityCard({super.key});

  static Color _aqiColor(int aqi) {
    if (aqi <= 50) return const Color(0xFF4CAF50);
    if (aqi <= 100) return const Color(0xFFFFB300);
    if (aqi <= 150) return const Color(0xFFFF6F00);
    if (aqi <= 200) return const Color(0xFFF44336);
    if (aqi <= 300) return const Color(0xFF9C27B0);
    return const Color(0xFF7B1FA2);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WeatherController>();
    final theme = Theme.of(context);

    return Obx(() {
      final aqi = controller.currentAqi;
      if (aqi == null) return const SizedBox.shrink();

      final label = controller.aqiLabel;
      final description = controller.aqiDescription;
      final color = _aqiColor(aqi);
      // Normalise AQI to a 0–1 progress value (scale: 0–300+)
      final progress = math.min(1.0, aqi / 300.0);

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AIR QUALITY',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.verified_outlined, size: 18, color: color),
                  ],
                ),
                const SizedBox(height: 12),
                // AQI number + label
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$aqi',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
