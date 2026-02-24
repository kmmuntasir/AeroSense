import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aero_sense/core/controllers/weather_controller.dart';

class InsightsCard extends StatelessWidget {
  const InsightsCard({super.key});

  static IconData _activityIcon(int? code, double? temp) {
    if (code == null) return Icons.park;
    if (code >= 95) return Icons.electric_bolt;
    if (code >= 71 && code <= 86) return Icons.ac_unit;
    if (code >= 51 && code <= 82) return Icons.umbrella;
    if (code == 45 || code == 48) return Icons.cloud;
    if ((temp ?? 20) > 32) return Icons.wb_sunny;
    if ((temp ?? 20) < 2) return Icons.thermostat;
    return Icons.park;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WeatherController>();
    final theme = Theme.of(context);

    return Obx(() {
      final title = controller.activityTitle;
      final description = controller.activityDescription;
      if (title.isEmpty) return const SizedBox.shrink();

      final weather = controller.currentWeather;
      final code = weather?.current.weatherCode;
      final temp = weather?.current.temperature2M;
      final icon = _activityIcon(code, temp);

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        // Outer container carries the shadow (must be outside ClipRRect
        // so it is not clipped away).
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0x1A2B3BEE),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000), // #0000000D — 5 % opacity
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: const BoxDecoration(
                  // Subtle white → lavender gradient matching the screenshot
                  gradient: LinearGradient(
                    colors: [Colors.white, Color(0xFFEEF0FF)],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon in a light lavender circle
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8E9F8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Color(0xFF3D3DBF), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
