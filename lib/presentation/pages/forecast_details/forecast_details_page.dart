import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:aero_sense/core/constants/app_constants.dart';
import 'package:aero_sense/core/models/forecast_response.dart';
import 'package:aero_sense/presentation/controllers/forecast_details_controller.dart';
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
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _CurrentWeatherCard(forecast: forecast),
              const SizedBox(height: 20),
              _DetailStatsGrid(forecast: forecast),
              const SizedBox(height: 20),
              _ChanceOfRainCard(forecast: forecast),
            ],
          ),
        );
      }),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Monday, Oct 24';
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

String _weatherCondition(int code) {
  if (code == 0) return 'Sunny';
  if (code == 1) return 'Mainly Clear';
  if (code == 2) return 'Partly Cloudy';
  if (code == 3) return 'Overcast';
  if (code == 45 || code == 48) return 'Foggy';
  if (code >= 51 && code <= 67) return 'Rainy';
  if (code >= 80 && code <= 82) return 'Rain Showers';
  if (code >= 71 && code <= 77) return 'Snowy';
  if (code >= 95 && code <= 99) return 'Thunderstorm';
  return 'Clear';
}

String _weatherDescription(int code) {
  if (code == 0 || code == 1) {
    return 'Clear skies with excellent visibility. Perfect conditions for activities.';
  }
  if (code == 2) {
    return 'Expect a mix of sun and clouds with a slight breeze in the afternoon. Perfect conditions for flight visibility.';
  }
  if (code == 3) {
    return 'Overcast conditions but no precipitation expected.';
  }
  if (code >= 51 && code <= 67) {
    return 'Light to moderate drizzle or rain expected. Carry an umbrella.';
  }
  if (code >= 71 && code <= 77) {
    return 'Moderate to heavy snow expected. Exercise caution on the roads.';
  }
  if (code >= 95 && code <= 99) {
    return 'Thunderstorm activity likely. Stay indoors if possible.';
  }
  return 'Current weather conditions are active.';
}

BoxDecoration _cardDecoration(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: cs.surface,
    borderRadius: BorderRadius.circular(AppConstants.cardRadius),
    boxShadow: [
      BoxShadow(
        color: cs.shadow.withValues(alpha: 0.07),
        blurRadius: 12,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

// ── Current Weather Card ──────────────────────────────────────────────────────

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
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top section: temp + condition + icon ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Temp number + condition stacked to its right
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${current.temperature.toStringAsFixed(0)}°',
                            style: tt.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                              fontSize: 56,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _weatherCondition(current.weatherCode),
                                style: tt.titleSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (firstDaily != null)
                                Text(
                                  'H:${firstDaily.maxTemperature.toStringAsFixed(0)}° L:${firstDaily.minTemperature.toStringAsFixed(0)}°',
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Feels like ${current.apparentTemperature.toStringAsFixed(0)}°',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _WeatherIconBubble(weatherCode: current.weatherCode),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            thickness: 1,
            color: cs.outlineVariant.withValues(alpha: 0.4),
            indent: 20,
            endIndent: 20,
          ),
          // ── Bottom section: description ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Text(
              _weatherDescription(current.weatherCode),
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weather Icon Bubble ───────────────────────────────────────────────────────

class _WeatherIconBubble extends StatelessWidget {
  final int weatherCode;

  const _WeatherIconBubble({required this.weatherCode});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    IconData icon;
    Color color;

    if (weatherCode == 0) {
      icon = Icons.sunny;
      color = const Color(0xFFFFA726);
    } else if (weatherCode == 1 || weatherCode == 2) {
      icon = Icons.wb_sunny_rounded;
      color = const Color(0xFFFFA726);
    } else if (weatherCode == 3) {
      icon = Icons.cloud_rounded;
      color = cs.onSurfaceVariant;
    } else if (weatherCode == 45 || weatherCode == 48) {
      icon = Icons.foggy;
      color = cs.onSurfaceVariant;
    } else if (weatherCode >= 51 && weatherCode <= 82) {
      icon = Icons.water_drop_rounded;
      color = cs.primary;
    } else if (weatherCode >= 71 && weatherCode <= 77) {
      icon = Icons.ac_unit_rounded;
      color = Colors.lightBlue;
    } else if (weatherCode >= 95) {
      icon = Icons.thunderstorm_rounded;
      color = const Color(0xFF7C4DFF);
    } else {
      icon = Icons.wb_sunny_rounded;
      color = const Color(0xFFFFA726);
    }

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 38, color: color),
    );
  }
}

// ── Detail Stats Grid ─────────────────────────────────────────────────────────

class _DetailStatsGrid extends StatelessWidget {
  final ForecastResponse forecast;

  const _DetailStatsGrid({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final hourly = forecast.hourly.getHoursAhead(1).firstOrNull;
    final humidity = hourly?.relativeHumidity ?? 45;
    final pressure = hourly?.pressure.toStringAsFixed(0) ?? '1012';
    final dewPoint = hourly != null ? _dewPoint(hourly) : '58';

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.05,
      children: [
        _StatCard(
          icon: Icons.water_drop_outlined,
          label: 'HUMIDITY',
          value: '$humidity',
          unit: '%',
          subtitle: 'Dew Point is $dewPoint°',
        ),
        _UVIndexCard(),
        _StatCard(
          icon: Icons.remove_red_eye_outlined,
          label: 'VISIBILITY',
          value: '10',
          unit: 'mi',
          subtitle: 'Clear view',
        ),
        _StatCard(
          icon: Icons.multiple_stop_rounded,
          label: 'PRESSURE',
          value: pressure,
          unit: 'hPa',
          subtitle: 'Stable',
        ),
      ],
    );
  }

  String _dewPoint(HourlyData hourly) {
    const a = 17.27;
    const b = 237.7;
    final alpha =
        ((a * hourly.temperature) / (b + hourly.temperature)) +
        (math.log(hourly.relativeHumidity / 100.0));
    final dp = (b * alpha) / (a - alpha);
    return dp.toStringAsFixed(0);
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
      decoration: _cardDecoration(context),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: tt.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: tt.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(
                  unit,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: tt.bodySmall?.copyWith(color: cs.primary)),
        ],
      ),
    );
  }
}

class _UVIndexCard extends StatelessWidget {
  const _UVIndexCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    const uvIndex = 4;

    return Container(
      decoration: _cardDecoration(context),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny_outlined, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                'UV INDEX',
                style: tt.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$uvIndex',
            style: tt.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 5,
              child: Row(
                children: [
                  Flexible(
                    flex: uvIndex,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green,
                            Colors.yellow,
                            Colors.orange,
                            Colors.red,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 10 - uvIndex,
                    child: Container(color: Colors.red.withValues(alpha: 0.15)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Moderate',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Chance of Rain Card ───────────────────────────────────────────────────────

class _ChanceOfRainCard extends StatelessWidget {
  final ForecastResponse forecast;

  const _ChanceOfRainCard({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final firstDaily = forecast.daily.getDaysAhead(1).firstOrNull;
    final precipChance = firstDaily?.precipitationProbability ?? 30;
    final hourlyData = forecast.hourly.getHoursAhead(24);

    return Container(
      decoration: _cardDecoration(context),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ─────────────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.cloud_outlined, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                'CHANCE OF RAIN',
                style: tt.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$precipChance% Peak',
                  style: tt.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ── Bezier curve chart ─────────────────────────────────────────
          SizedBox(
            height: 120,
            child: _RainCurveChart(hourlyData: hourlyData, color: cs.primary),
          ),
        ],
      ),
    );
  }
}

// ── Rain Curve Chart ──────────────────────────────────────────────────────────

class _RainCurveChart extends StatelessWidget {
  final List<HourlyData> hourlyData;
  final Color color;

  const _RainCurveChart({required this.hourlyData, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 120),
      painter: _RainCurvePainter(hourlyData: hourlyData, color: color),
    );
  }
}

class _RainCurvePainter extends CustomPainter {
  final List<HourlyData> hourlyData;
  final Color color;

  _RainCurvePainter({required this.hourlyData, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (hourlyData.length < 2) return;

    final probs = hourlyData.map((h) => h.precipitationProbability).toList();
    final maxVal = probs.reduce((a, b) => a > b ? a : b).clamp(1.0, 100.0);

    // Chart area with padding
    const topPad = 20.0;
    const bottomPad = 28.0;
    final chartH = size.height - topPad - bottomPad;
    final stepX = size.width / (probs.length - 1);

    List<Offset> points = [];
    for (int i = 0; i < probs.length; i++) {
      final x = i * stepX;
      final y = topPad + chartH - (probs[i] / maxVal) * chartH;
      points.add(Offset(x, y));
    }

    // Find peak point for marker
    int peakIdx = 0;
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > probs[peakIdx]) peakIdx = i;
    }

    // Filled gradient area
    final gradientPath = _buildCurvePath(points);
    gradientPath.lineTo(size.width, size.height - bottomPad);
    gradientPath.lineTo(0, size.height - bottomPad);
    gradientPath.close();

    final shader = ui.Gradient.linear(
      Offset(0, topPad),
      Offset(0, size.height - bottomPad),
      [color.withValues(alpha: 0.18), color.withValues(alpha: 0.0)],
    );

    canvas.drawPath(gradientPath, Paint()..shader = shader);

    // Baseline rule
    canvas.drawLine(
      Offset(0, size.height - bottomPad),
      Offset(size.width, size.height - bottomPad),
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..strokeWidth = 1,
    );

    // Main curve line
    canvas.drawPath(
      _buildCurvePath(points),
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Peak marker circle (open circle with filled center)
    if (points.isNotEmpty) {
      final peak = points[peakIdx];
      canvas
        ..drawCircle(
          peak,
          7,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        )
        ..drawCircle(
          peak,
          7,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        )
        ..drawCircle(
          peak,
          3,
          Paint()
            ..color = color
            ..style = PaintingStyle.fill,
        );
    }

    // Time labels at bottom
    final labelStyle = TextStyle(
      color: color.withValues(alpha: 0.5),
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );
    const labelCount = 5;
    final step = (points.length - 1) ~/ (labelCount - 1);
    for (int i = 0; i < labelCount; i++) {
      final idx = (i * step).clamp(0, points.length - 1);
      final time = hourlyData[idx].time;
      final label =
          '${time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour)}${time.hour < 12 ? 'am' : 'pm'}';
      final tp = TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(points[idx].dx - tp.width / 2, size.height - bottomPad + 6),
      );
    }
  }

  Path _buildCurvePath(List<Offset> points) {
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final cp1 = Offset((points[i].dx + points[i + 1].dx) / 2, points[i].dy);
      final cp2 = Offset(
        (points[i].dx + points[i + 1].dx) / 2,
        points[i + 1].dy,
      );
      path.cubicTo(
        cp1.dx,
        cp1.dy,
        cp2.dx,
        cp2.dy,
        points[i + 1].dx,
        points[i + 1].dy,
      );
    }
    return path;
  }

  @override
  bool shouldRepaint(_RainCurvePainter old) =>
      old.hourlyData != hourlyData || old.color != color;
}

// ── Error State ───────────────────────────────────────────────────────────────

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
              onPressed: () =>
                  Get.find<ForecastDetailsController>().refreshForecast(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
