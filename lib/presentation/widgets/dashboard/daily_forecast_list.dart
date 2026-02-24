import 'package:aero_sense/core/constants/wmo_icons.dart';
import 'package:aero_sense/core/controllers/weather_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class DailyForecastList extends StatelessWidget {
  const DailyForecastList({super.key});

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WeatherController>();
    final theme = Theme.of(context);

    return Obx(() {
      final daily = controller.dailyForecast;
      if (daily.isEmpty) return const SizedBox.shrink();

      // Compute global min/max for relative range bar
      final mins = daily.map((d) => d.minTemperature2M ?? 0.0).toList();
      final maxs = daily.map((d) => d.maxTemperature2M ?? 0.0).toList();
      final globalMin = mins.reduce((a, b) => a < b ? a : b);
      final globalMax = maxs.reduce((a, b) => a > b ? a : b);

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '5-Day Forecast',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Card(
              color: Colors.transparent,
              elevation: 0,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: daily.length,
                // separatorBuilder: (context, _) => Divider(
                //   height: 1,
                //   color: theme.colorScheme.outline.withValues(alpha: 0.15),
                // ),
                itemBuilder: (context, index) {
                  final day = daily[index];
                  final weekday = _weekdays[day.date.weekday - 1];
                  final isToday = index == 0;
                  final label = isToday ? 'Today' : weekday;
                  final iconPath = WmoIcons.getIconPath(day.weatherCode);
                  final minTemp = day.minTemperature2M ?? 0.0;
                  final maxTemp = day.maxTemperature2M ?? 0.0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 52,
                          child: Text(
                            label,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SvgPicture.asset(iconPath, width: 28, height: 28),

                        const SizedBox(width: 10),
                        Expanded(
                          child: _TempRangeBar(
                            dayMin: minTemp,
                            dayMax: maxTemp,
                            globalMin: globalMin,
                            globalMax: globalMax,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 36,
                          child: Text(
                            controller.getTemperatureDisplay(minTemp),
                            textAlign: TextAlign.end,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 36,
                          child: Text(
                            controller.getTemperatureDisplay(maxTemp),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }
}

class _TempRangeBar extends StatelessWidget {
  const _TempRangeBar({
    required this.dayMin,
    required this.dayMax,
    required this.globalMin,
    required this.globalMax,
  });

  static const Color _barStart = Color(0xFF7B8FFF);
  static const Color _barEnd = Color(0xFF2B3BEE);

  final double dayMin;
  final double dayMax;
  final double globalMin;
  final double globalMax;

  @override
  Widget build(BuildContext context) {
    final range = globalMax - globalMin;
    final startFraction = range > 0 ? (dayMin - globalMin) / range : 0.0;
    final endFraction = range > 0 ? (dayMax - globalMin) / range : 1.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final barStart = startFraction * width;
        final barWidth = (endFraction - startFraction) * width;

        return SizedBox(
          height: 8,
          child: Stack(
            children: [
              Positioned(
                left: barStart,
                width: barWidth.clamp(16.0, width),
                child: Container(
                  height: 8,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [_barStart, _barEnd]),
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
