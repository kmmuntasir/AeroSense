import 'package:aero_sense/core/constants/wmo_icons.dart';
import 'package:aero_sense/core/controllers/weather_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class HourlyForecastList extends StatelessWidget {
  const HourlyForecastList({super.key});

  static const Color _activeColor = Color(0xFF2B3BEE);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WeatherController>();
    final theme = Theme.of(context);

    return Obx(() {
      final hourly = controller.hourlyForecast;
      if (hourly.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hourly Forecast',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'View All',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _activeColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Scrollable hourly cards
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: hourly.length,
              itemBuilder: (context, index) {
                final item = hourly[index];
                final isNow = index == 0;
                final hour = item.time.hour;
                final timeLabel = isNow
                    ? 'Now'
                    : '${hour == 0
                              ? 12
                              : hour > 12
                              ? hour - 12
                              : hour}'
                          ' ${hour < 12 ? 'AM' : 'PM'}';
                final iconPath = WmoIcons.getIconPath(item.weatherCode);
                final temp = item.temperature2M != null
                    ? controller.getTemperatureDisplay(item.temperature2M!)
                    : '—';

                return GestureDetector(
                  onTap: () => isNow ? Get.toNamed('/forecast-details') : null,

                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      width: 72,
                      decoration: BoxDecoration(
                        color: isNow ? _activeColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isNow
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            timeLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isNow
                                  ? Colors.white
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.45,
                                    ),
                              fontWeight: isNow
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SvgPicture.asset(
                            iconPath,
                            width: 32,
                            height: 32,
                            colorFilter: isNow
                                ? const ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            temp,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isNow
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    });
  }
}
