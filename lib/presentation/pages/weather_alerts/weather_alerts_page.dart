import 'package:aero_sense/core/constants/app_constants.dart';
import 'package:aero_sense/presentation/controllers/weather_alerts_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class WeatherAlertsPage extends GetView<WeatherAlertsController> {
  const WeatherAlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Weather Alerts'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _ActiveWarningCard(controller: controller),
          const SizedBox(height: 28),
          _PastAlertsSection(alerts: controller.pastAlerts),
          const SizedBox(height: 24),
          _ManageNotificationsLink(),
        ],
      ),
    );
  }
}

// ── Active Warning Card ────────────────────────────────────────────────────────

class _ActiveWarningCard extends StatelessWidget {
  final WeatherAlertsController controller;

  const _ActiveWarningCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.onError, cs.errorContainer],
        ),
        boxShadow: [
          BoxShadow(
            color: cs.onError.withAlpha(50),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius - 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AlertHeader(controller: controller),
            const SizedBox(height: 10),

            _LocationRow(controller: controller),
            const SizedBox(height: 12),
            Text(
              controller.alertDescription,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            _AlertMap(controller: controller),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1),
            ),
            _MoreDetailsRow(controller: controller),
            const SizedBox(height: 10),
            _NwsCard(controller: controller),
            const SizedBox(height: 16),
            _ReadReportButton(),
          ],
        ),
      ),
    );
  }
}

// ── Alert Header Row ───────────────────────────────────────────────────────────

class _AlertHeader extends StatelessWidget {
  final WeatherAlertsController controller;

  const _AlertHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cs.error.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.warning_amber_rounded, color: cs.onError, size: 22),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.alertType,
              style: tt.labelMedium?.copyWith(
                color: cs.onError,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            Text(controller.alertTitle, style: tt.titleMedium),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: cs.onError,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'LIVE',
            style: tt.labelSmall?.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Location Row ──────────────────────────────────────────────────────────────

class _LocationRow extends StatelessWidget {
  final WeatherAlertsController controller;

  const _LocationRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 16, color: cs.primary),
        const SizedBox(width: 4),
        Text(
          controller.alertLocation,
          style: tt.bodySmall?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '•',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        Text(
          controller.alertUntil,
          style: tt.bodySmall?.copyWith(
            color: cs.onError,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Alert Map ─────────────────────────────────────────────────────────────

class _AlertMap extends StatelessWidget {
  final WeatherAlertsController controller;

  const _AlertMap({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final center = LatLng(controller.alertLatitude, controller.alertLongitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.cardRadius - 4),
      child: SizedBox(
        height: 160,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 10,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.aerosense.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 36,
                  height: 36,
                  child: Icon(Icons.location_on, color: cs.error, size: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── More Details Row ──────────────────────────────────────────────────────────

class _MoreDetailsRow extends StatelessWidget {
  final WeatherAlertsController controller;

  const _MoreDetailsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(
          'More Details',
          style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        GestureDetector(
          onTap: controller.toggleExpand,
          child: Obx(
            () => Row(
              children: [
                Text(
                  controller.isExpanded.value
                      ? 'Collapse Report'
                      : 'Expand Report',
                  style: tt.bodySmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  controller.isExpanded.value
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 18,
                  color: cs.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── NWS Source Card ───────────────────────────────────────────────────────────

class _NwsCard extends StatelessWidget {
  final WeatherAlertsController controller;

  const _NwsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius - 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                controller.nwsSource,
                style: tt.labelSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(controller.nwsPreview, style: tt.bodySmall),
        ],
      ),
    );
  }
}

// ── Read Full Report Button ───────────────────────────────────────────────────

class _ReadReportButton extends StatelessWidget {
  const _ReadReportButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.article_outlined, size: 18),
      label: const Text('Read Full Report'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}

// ── Past Alerts Section ───────────────────────────────────────────────────────

class _PastAlertsSection extends StatelessWidget {
  final List<PastAlert> alerts;

  const _PastAlertsSection({required this.alerts});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Past 24 Hours',
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...alerts.map(
          (alert) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _PastAlertRow(alert: alert),
          ),
        ),
      ],
    );
  }
}

// ── Past Alert Row ────────────────────────────────────────────────────────────

class _PastAlertRow extends StatelessWidget {
  final PastAlert alert;

  const _PastAlertRow({required this.alert});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(alert.icon, size: 18, color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alert.location,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Expired',
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Manage Notifications Link ─────────────────────────────────────────────────

class _ManageNotificationsLink extends StatelessWidget {
  const _ManageNotificationsLink();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Manage Alert Notifications',
            style: tt.bodyMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.arrow_forward, size: 16, color: cs.primary),
        ],
      ),
    );
  }
}
