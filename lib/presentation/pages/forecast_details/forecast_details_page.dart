import 'package:aero_sense/core/constants/app_constants.dart';
import 'package:aero_sense/core/themes/app_theme.dart';
import 'package:aero_sense/presentation/controllers/forecast_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForecastDetailsPage extends GetView<ForecastDetailsController> {
  const ForecastDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surfaceContainer;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: bg,
        surfaceTintColor: bg,
        title: Text(
          controller.formattedDate,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.ios_share_outlined),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _HeroCard(controller: controller),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildHumidityCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildUvCard()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildVisibilityCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildPressureCard()),
            ],
          ),
          const SizedBox(height: 12),
          _PrecipCard(controller: controller),
        ],
      ),
    );
  }

  Widget _buildHumidityCard() => _MetricCard(
    icon: Icons.water_drop_outlined,
    label: 'HUMIDITY',
    value: '${controller.humidity}%',
    subtitle: 'Dew Point is ${controller.dewPoint}°',
  );

  Widget _buildUvCard() => _MetricCard(
    icon: Icons.wb_sunny_outlined,
    label: 'UV INDEX',
    value: '${controller.uvIndex}',
    subtitle: controller.uvLabel,
    extra: _UvBar(fraction: controller.uvFraction),
  );

  Widget _buildVisibilityCard() => _MetricCard(
    icon: Icons.visibility_outlined,
    label: 'VISIBILITY',
    value: '${controller.visibility} mi',
    subtitle: controller.visibilityLabel,
  );

  Widget _buildPressureCard() => _MetricCard(
    icon: Icons.compress,
    label: 'PRESSURE',
    value: '${controller.pressure}',
    valueUnit: 'hPa',
    subtitle: controller.pressureLabel,
  );
}

// ── Hero Card ──────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final ForecastDetailsController controller;

  const _HeroCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.surface, cs.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(AppConstants.heroRadius),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${controller.temperature}°',
                  style: tt.displayLarge?.copyWith(
                    fontSize: AppConstants.tempFontSize,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.condition,
                        style: tt.titleMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'H:${controller.highTemp}° L:${controller.lowTemp}°',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      controller.weatherEmoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Feels like ${controller.feelsLike}°',
              style: tt.bodyLarge?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, thickness: 1),
            ),
            Text(
              controller.weatherInsight,
              style: tt.bodyMedium?.copyWith(color: cs.onSurface, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Metric Card ────────────────────────────────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? valueUnit;
  final Widget? extra;
  final String subtitle;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueUnit,
    this.extra,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: tt.labelSmall?.copyWith(
                    color: cs.primary,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          valueUnit != null
              ? RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: tt.displaySmall?.copyWith(
                          fontSize: AppConstants.metricValueFontSize,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: ' $valueUnit',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : Text(
                  value,
                  style: tt.displaySmall?.copyWith(
                    fontSize: AppConstants.metricValueFontSize,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
          if (extra != null) ...[const SizedBox(height: 10), extra!],
          const SizedBox(height: 6),
          Text(subtitle, style: tt.bodySmall?.copyWith(color: cs.primary)),
        ],
      ),
    );
  }
}

// ── UV Index Bar ───────────────────────────────────────────────────────────────

class _UvBar extends StatelessWidget {
  final double fraction;

  const _UvBar({required this.fraction});

  @override
  Widget build(BuildContext context) {
    final trackColor = Theme.of(context).colorScheme.outlineVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: trackColor.withAlpha(80),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Container(
              height: 6,
              width: constraints.maxWidth * fraction,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.uvLow,
                    AppTheme.uvModerate,
                    AppTheme.uvHigh,
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Precipitation Card ────────────────────────────────────────────────────────

class _PrecipCard extends StatelessWidget {
  final ForecastDetailsController controller;

  const _PrecipCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Icon(Icons.grain, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'CHANCE OF RAIN',
                  style: tt.labelSmall?.copyWith(
                    color: cs.primary,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.peakPercent}% Peak',
                    style: tt.labelSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 130,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppConstants.cardRadius),
              ),
              child: CustomPaint(
                painter: _PrecipChartPainter(
                  values: controller.hourlyPrecip,
                  lineColor: cs.primary,
                  gridColor: cs.outlineVariant.withAlpha(50),
                  surfaceColor: cs.surface,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Precipitation Chart Painter ───────────────────────────────────────────────

class _PrecipChartPainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color gridColor;
  final Color surfaceColor;

  const _PrecipChartPainter({
    required this.values,
    required this.lineColor,
    required this.gridColor,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final n = values.length;
    const topPad = 16.0;
    const bottomPad = 8.0;
    final chartHeight = size.height - topPad - bottomPad;

    // Grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (int i = 1; i <= 2; i++) {
      final y = topPad + chartHeight * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Data → canvas coordinates (values are 0.0–1.0)
    final points = List<Offset>.generate(n, (i) {
      final x = size.width * i / (n - 1);
      final y = topPad + chartHeight * (1.0 - values[i]);
      return Offset(x, y);
    });

    // Smooth bezier path
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < n - 1; i++) {
      final midX = (points[i].dx + points[i + 1].dx) / 2;
      path.cubicTo(
        midX,
        points[i].dy,
        midX,
        points[i + 1].dy,
        points[i + 1].dx,
        points[i + 1].dy,
      );
    }

    // Gradient fill
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [lineColor.withAlpha(65), lineColor.withAlpha(0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Curve line
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Peak dot
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final maxIdx = values.indexOf(maxVal);
    final peakX = size.width * maxIdx / (n - 1);
    final peakY = topPad + chartHeight * (1.0 - maxVal);

    canvas.drawCircle(Offset(peakX, peakY), 5, Paint()..color = surfaceColor);
    canvas.drawCircle(
      Offset(peakX, peakY),
      5,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _PrecipChartPainter old) =>
      old.values != values ||
      old.lineColor != lineColor ||
      old.gridColor != gridColor ||
      old.surfaceColor != surfaceColor;
}
