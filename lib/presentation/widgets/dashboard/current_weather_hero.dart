import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:aero_sense/core/controllers/weather_controller.dart';
import 'package:aero_sense/core/constants/wmo_icons.dart';

class CurrentWeatherHero extends StatelessWidget {
  const CurrentWeatherHero({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WeatherController>();
    final theme = Theme.of(context);

    return Obx(() {
      final weather = controller.currentWeather;
      if (weather == null) return const SizedBox.shrink();

      final current = weather.current;
      final daily = controller.dailyForecast;
      final iconPath = WmoIcons.getIconPath(current.weatherCode);
      final condition = controller.getWeatherCondition(current.weatherCode);
      final temp = controller.getTemperatureDisplay(current.temperature2M ?? 0);

      final highLow = daily.isNotEmpty
          ? 'High ${controller.getTemperatureDisplay(daily.first.maxTemperature2M ?? 0)} '
                '· Low ${controller.getTemperatureDisplay(daily.first.minTemperature2M ?? 0)}'
          : null;

      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          children: [
            // Temperature + icon side-by-side
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  temp,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 80,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 12),
                SvgPicture.asset(iconPath, width: 40, height: 40),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              condition,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            if (highLow != null) ...[
              const SizedBox(height: 4),
              Text(
                highLow,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
