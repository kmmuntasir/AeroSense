import 'package:aero_sense/core/constants/app_constants.dart';
import 'package:aero_sense/core/models/forecast_response.dart';
import 'package:aero_sense/presentation/controllers/forecast_details_controller.dart';
import 'package:aero_sense/presentation/widgets/common_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForecastDetailsPage extends GetView<ForecastDetailsController> {
  const ForecastDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => Text(
            controller.forecast != null
                ? _formatDate(controller.forecast!.daily.dates.firstOrNull)
                : 'Monday, Oct 24',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: const CommonBottomNav(selectedIndex: 3),
      body: Obx(
        () {
          if (controller.isLoading && controller.forecast == null) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (controller.errorMessage.isNotEmpty && controller.forecast == null) {
            return _ErrorState(errorMessage: controller.errorMessage);
          }

          final forecast = controller.forecast;
          if (forecast == null) {
            return const Center(child: Text('No forecast data available'));
          }

          return RefreshIndicator(
            onRefresh: () => controller.refreshForecast(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _CurrentWeatherCard(forecast: forecast),
                const SizedBox(height: 24),
                _DetailStatsGrid(forecast: forecast),
                const SizedBox(height: 24),
                _ChanceOfRainSection(forecast: forecast),
                const SizedBox(height: 24),
                _TemperatureTrendChart(forecast: forecast),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Monday, Oct 24';
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}

// ── Current Weather Card ────────────────────────────────────────────────────

class _CurrentWeatherCard extends StatelessWidget {
  final ForecastResponse forecast;

  const _CurrentWeatherCard({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final current = forecast.current;
    final firstDaily = forecast.daily.getDaysAhead(1).firstOrNull;

    return Container(
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${current.temperature.toStringAsFixed(0)}°',
                      style: tt.displayLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getWeatherCondition(current.weatherCode),
                      style: tt.bodyMedium?.copyWith(color: cs.primary),
                    ),
                    const SizedBox(height: 2),
                    if (firstDaily != null)
                      Text(
                        'H:${firstDaily.maxTemperature.toStringAsFixed(0)}° L:${firstDaily.minTemperature.toStringAsFixed(0)}°',
                        style: tt.labelMedium,
                      ),
                  ],
                ),
              ),
              _WeatherIcon(weatherCode: current.weatherCode),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Feels like ${current.apparentTemperature.toStringAsFixed(0)}°',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Text(
            _getWeatherDescription(current.weatherCode),
            style: tt.bodyMedium?.copyWith(
              height: 1.6,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getWeatherCondition(int code) {
    if (code == 0 || code == 1) return 'Sunny';
    if (code == 2) return 'Partly Cloudy';
    if (code == 3) return 'Overcast';
    if (code == 45 || code == 48) return 'Foggy';
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) return 'Rainy';
    if (code >= 71 && code <= 77) return 'Snowy';
    if (code >= 90 && code <= 99) return 'Thunderstorm';
    return 'Clear';
  }

  String _getWeatherDescription(int code) {
    if (code == 0 || code == 1) {
      return 'Clear skies with excellent visibility. Perfect conditions for activities.';
    } else if (code == 2) {
      return 'Mix of sun and clouds with a slight breeze. Perfect conditions for flight visibility.';
    } else if (code == 3) {
      return 'Overcast conditions but no precipitation expected.';
    } else if (code >= 51 && code <= 67) {
      return 'Light to moderate drizzle or rain expected. Conditions suitable for most activities.';
    } else if (code >= 71 && code <= 77) {
      return 'Moderate to heavy snow expected. Exercise caution in hazardous conditions.';
    }
    return 'Current weather conditions active.';
  }
}

// ── Weather Icon ────────────────────────────────────────────────────────────

class _WeatherIcon extends StatelessWidget {
  final int weatherCode;

  const _WeatherIcon({required this.weatherCode});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    IconData icon = Icons.cloud;
    Color color = cs.primary;

    if (weatherCode == 0) {
      icon = Icons.sunny;
      color = Colors.amber;
    } else if (weatherCode == 1 || weatherCode == 2) {
      icon = Icons.wb_sunny;
      color = Colors.orange;
    } else if (weatherCode == 3) {
      icon = Icons.cloud;
    } else if (weatherCode >= 51 && weatherCode <= 67) {
      icon = Icons.water_drop;
      color = cs.primary;
    } else if (weatherCode >= 71 && weatherCode <= 77) {
      icon = Icons.ac_unit;
      color = Colors.lightBlue;
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 40, color: color),
    );
  }
}

// ── Detail Stats Grid ───────────────────────────────────────────────────────

class _DetailStatsGrid extends StatelessWidget {
  final ForecastResponse forecast;

  const _DetailStatsGrid({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final firstHourly = forecast.hourly.getHoursAhead(24).firstOrNull;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
          icon: Icons.opacity_outlined,
          label: 'HUMIDITY',
          value: firstHourly?.relativeHumidity.toString() ?? '45',
          unit: '%',
          subtitle: firstHourly != null ? 'Dew Point is ${_calculateDewPoint(firstHourly)}°' : 'Dew Point is 58°',
        ),
        _StatCard(
          icon: Icons.wb_sunny_outlined,
          label: 'UV INDEX',
          value: '4',
          unit: '',
          subtitle: 'Moderate',
        ),
        _StatCard(
          icon: Icons.visibility_outlined,
          label: 'VISIBILITY',
          value: '10',
          unit: 'mi',
          subtitle: 'Clear view',
        ),
        _StatCard(
          icon: Icons.air_outlined,
          label: 'PRESSURE',
          value: (firstHourly?.pressure.toStringAsFixed(0) ?? '1012'),
          unit: 'hPa',
          subtitle: 'Stable',
        ),
      ],
    );
  }

  String _calculateDewPoint(HourlyData hourly) {
    final temp = hourly.temperature;
    final humidity = hourly.relativeHumidity;
    final a = 17.27;
    final b = 237.7;
    final alpha = ((a * temp) / (b + temp)) + (humidity / 100).log();
    final dewPoint = (b * alpha) / (a - alpha);
    return dewPoint.toStringAsFixed(0);
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: tt.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: tt.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (unit.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    unit,
                    style: tt.bodySmall,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Chance of Rain Section ──────────────────────────────────────────────────

class _ChanceOfRainSection extends StatelessWidget {
  final ForecastResponse forecast;

  const _ChanceOfRainSection({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final firstDaily = forecast.daily.getDaysAhead(1).firstOrNull;
    final precipChance = firstDaily?.precipitationProbability ?? 30;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_outlined, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'CHANCE OF RAIN',
                style: tt.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  '$precipChance% Peak',
                  style: tt.labelSmall?.copyWith(color: cs.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: precipChance / 100,
              minHeight: 6,
              backgroundColor: cs.outlineVariant.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Temperature Trend Chart ─────────────────────────────────────────────────

class _TemperatureTrendChart extends StatelessWidget {
  final ForecastResponse forecast;

  const _TemperatureTrendChart({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hourlyData = forecast.hourly.getHoursAhead(24);

    if (hourlyData.isEmpty) {
      return const SizedBox.shrink();
    }

    final minTemp = hourlyData.map((e) => e.temperature).reduce((a, b) => a < b ? a : b);
    final maxTemp = hourlyData.map((e) => e.temperature).reduce((a, b) => a > b ? a : b);
    final range = maxTemp - minTemp + 2;

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: CustomPaint(
        painter: _TrendChartPainter(
          data: hourlyData,
          minTemp: minTemp,
          range: range,
          color: cs.primary,
        ),
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final List<HourlyData> data;
  final double minTemp;
  final double range;
  final Color color;

  _TrendChartPainter({
    required this.data,
    required this.minTemp,
    required this.range,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final pointSpacing = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * pointSpacing;
      final y = size.height - ((data[i].temperature - minTemp) / range * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i += 4) {
      final x = i * pointSpacing;
      final y = size.height - ((data[i].temperature - minTemp) / range * size.height);
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(_TrendChartPainter oldDelegate) => false;
}

// ── Error State ─────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String errorMessage;

  const _ErrorState({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_outlined, size: 48, color: cs.error),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Forecast',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.find<ForecastDetailsController>().refreshForecast(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
