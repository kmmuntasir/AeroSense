import 'dart:math' as math;

import 'package:aero_sense/core/controllers/weather_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';

class WindCard extends StatelessWidget {
  const WindCard({super.key});

  static const Color _accentColor = Color(0xFF2B3BEE);
  static const Color _pillBg = Color(0xFFEEF0FF);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WeatherController>();
    final theme = Theme.of(context);

    return Obx(() {
      final weather = controller.currentWeather;
      if (weather == null) return const SizedBox.shrink();

      final current = weather.current;
      final speedMs = current.windSpeed10M ?? 0.0;
      final speedMph = (speedMs * 2.237).round();
      final directionDeg = current.windDirection10M ?? 0.0;
      final directionLabel = current.windDirection10M != null
          ? controller.getWindDirection(current.windDirection10M!)
          : '—';
      final condition = controller.windCondition;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(24)),
            border: BoxBorder.all(color: AppColors.dashboardCardBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.dashboardBoxShadow,
                offset: const Offset(0, 1),
                blurRadius: 2,
                spreadRadius: 0,
              ),
            ],
          ),
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
                      'WIND',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.air, size: 20, color: _accentColor),
                  ],
                ),
                const SizedBox(height: 16),
                // Compass + speed/direction row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Compass circle
                    _CompassDial(
                      directionDeg: directionDeg,
                      accentColor: _accentColor,
                      theme: theme,
                    ),
                    const SizedBox(width: 16),
                    // Speed + direction
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$speedMph',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'mph',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.55,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Direction: $directionLabel',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.55,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Condition pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _pillBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    condition,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _accentColor,
                      fontWeight: FontWeight.w600,
                    ),
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

class _CompassDial extends StatelessWidget {
  const _CompassDial({
    required this.directionDeg,
    required this.accentColor,
    required this.theme,
  });

  final double directionDeg;
  final Color accentColor;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // "N" label at the top
          Positioned(
            top: 8,
            child: Text(
              'N',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
          // Arrow rotated to wind direction
          Transform.rotate(
            angle: directionDeg * math.pi / 180,
            child: Icon(Icons.navigation, size: 26, color: accentColor),
          ),
        ],
      ),
    );
  }
}
