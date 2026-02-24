import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/controllers/location_controller.dart';

/// OnboardingPage handles the first-launch experience.
/// It shows a loading state while checking location permission,
/// then routes the user appropriately:
/// - Location granted: Navigate to Dashboard
/// - Location denied: Navigate to Search/Fallback view
//class OnboardingPage extends StatefulWidget {
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/common_icon.dart';
import '../../controllers/onboarding_controller.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    return Scaffold(
      // Steps 2 & 3 use #F6F6F8; Step 1 is #F6F7F8 — diff is 1 green unit, undetectable
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: PageView(
          controller: controller.pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _LocationPage(),
            _NotificationsPage(),
            _GetStartedPage(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _OnboardingProgressDots extends StatelessWidget {
  final int activeIndex;
  const _OnboardingProgressDots({required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.progressDotActive
                : AppColors.progressDotInactive,
            borderRadius: BorderRadius.circular(4),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.progressDotActive.withValues(alpha: 0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

  /*Future<void> _initializeOnboarding() async {
    // Read the real permission status directly — avoids a race condition
    // with LocationController._checkLocationPermission() (not awaited in onInit).
    final status = await Permission.location.status;

    if (status.isPermanentlyDenied) {
      if (mounted) Get.offAllNamed('/search');
      return;
    }

    // Request permission (no-op / returns current status if already granted)
    final granted = await _locationController.requestLocationPermission();
    if (!granted) {
      if (mounted) Get.offAllNamed('/search');
      return;
    }

    final success = await _locationController.getCurrentLocation();
    if (mounted) {
      Get.offAllNamed(success ? '/dashboard' : '/search');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sky Indigo weather icon (sun/cloud)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.cloud, size: 64, color: Colors.white),*/
class _OnboardingPrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double fontSize;

  const _OnboardingPrimaryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: -3,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double fontSize;

  const _OnboardingSecondaryButton({
    required this.label,
    required this.onTap,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(minimumSize: const Size(342, 40)),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.spaceGrotesk(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 1 – Location Access
// ---------------------------------------------------------------------------

class _LocationPage extends StatelessWidget {
  const _LocationPage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top nav — Skip button right-aligned, 84px tall
        SizedBox(
          height: 84,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 44, 24, 0),
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: controller.onEnterManually,
                child: Text(
                  'Skip',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    height: 1.43,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Main content — illustration + text
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Illustration fills available space, scales down on small screens
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: const _LocationIllustration(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Heading — exact Figma copy & line break
                Text(
                  'Where in the world are\nyou?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 12),
                // Body — exact Figma copy
                Text(
                  'AeroSense needs access to your location to provide real-time local weather insights and hyper-local storm tracking.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textBody,
                    height: 1.625,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom actions — 216px
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _OnboardingPrimaryButton(
                label: 'Enable Location',
                icon: Icons.my_location_rounded,
                color: AppColors.locationButton,
                onTap: controller.onEnableLocation,
                fontSize: 18,
              ),
              const SizedBox(height: 16),
              _OnboardingSecondaryButton(
                label: 'Enter location manually',
                onTap: controller.onEnterManually,
                fontSize: 16,
              ),
              const SizedBox(height: 16),
              const _OnboardingProgressDots(activeIndex: 0),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationIllustration extends StatelessWidget {
  const _LocationIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main illustration — img_location_illustration.png (Figma 10:176)
          ClipOval(
            child: const CommonIcon(
              path: AppAssets.imgLocationIllustration,
              width: 260,
              height: 260,
              fit: BoxFit.cover,
            ),
          ),
          // Top-right decorative PNG — ic_location_deco_top.png (Figma 10:178, 48×48)
          Positioned(
            top: 16,
            right: 12,
            child: const CommonIcon(
              path: AppAssets.icLocationDecoTop,
              width: 48,
              height: 48,
            ),
          ),
          // Bottom-left decorative PNG — ic_location_deco_bottom.png (Figma 10:182, 40×40)
          Positioned(
            bottom: 16,
            left: 12,
            child: const CommonIcon(
              path: AppAssets.icLocationDecoBottom,
              width: 40,
              height: 40,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 2 – Notifications
// ---------------------------------------------------------------------------

class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress dots at top
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 32, 0, 0),
          child: Center(child: _OnboardingProgressDots(activeIndex: 1)),
        ),

        // Main content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Illustration fills available space, scales down on small screens
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: const _NotificationsIllustration(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Heading — exact Figma copy & line break
                Text(
                  'Stay ahead of the\nstorm',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.09,
                  ),
                ),
                const SizedBox(height: 12),
                // Body — exact Figma copy
                Text(
                  'Never get caught in the rain again. Enable permissions to receive real-time severe weather alerts and your morning forecast summary.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.625,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom actions
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _OnboardingPrimaryButton(
                label: 'Turn on Notifications',
                icon: Icons.notifications_active_rounded,
                color: AppColors.notificationButton,
                onTap: controller.onEnableNotifications,
                fontSize: 17,
              ),
              const SizedBox(height: 16),
              // "Maybe later" — 15px per Figma
              _OnboardingSecondaryButton(
                label: 'Maybe later',
                onTap: controller.onMaybeLater,
                fontSize: 15,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationsIllustration extends StatelessWidget {
  const _NotificationsIllustration();

  @override
  Widget build(BuildContext context) {
    // img_notifications_illustration.png — Figma node 10:214 (256×256 PNG)
    return const CommonIcon(
      path: AppAssets.imgNotificationsIllustration,
      width: 260,
      height: 260,
    );
  }
}

// ---------------------------------------------------------------------------
// Page 3 – Get Started
// ---------------------------------------------------------------------------

class _GetStartedPage extends StatelessWidget {
  const _GetStartedPage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress dots at top
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Center(child: _OnboardingProgressDots(activeIndex: 2)),
        ),

        // Main content — illustration fills full content width (Figma: 342×374)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Illustration height is flexible; capped at Figma max of 280
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final h = constraints.maxHeight.clamp(160.0, 280.0);
                      return _GetStartedIllustration(height: h);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Heading — exact Figma line break
                Text(
                  'Your personal\nweather, your way',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.09,
                  ),
                ),
                const SizedBox(height: 12),
                // Body — exact Figma copy
                Text(
                  'AeroSense adapts to you. Remember, you can always customize your measurement units and color themes later in Settings.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textBody,
                    height: 1.625,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom actions — fade gradient bg per Figma
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.5, 1],
              colors: [
                AppColors.pageBackground.withValues(alpha: 0),
                AppColors.pageBackground,
                AppColors.pageBackground,
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _OnboardingPrimaryButton(
                label: 'Get Started',
                icon: Icons.arrow_forward_rounded,
                color: AppColors.getStartedButton,
                onTap: controller.onGetStarted,
                fontSize: 18,
              ),
              const SizedBox(height: 16),
              // "Skip setup for now" — 14px per Figma
              _OnboardingSecondaryButton(
                label: 'Skip setup for now',
                onTap: controller.onSkipSetup,
                fontSize: 14,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GetStartedIllustration extends StatelessWidget {
  final double height;
  const _GetStartedIllustration({this.height = 280});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        // Figma: linear-gradient(180deg, rgba(43,59,238,0.05) 0%, rgba(43,59,238,0) 100%)
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.getStartedButton.withValues(alpha: 0.05),
            AppColors.getStartedButton.withValues(alpha: 0.0),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Main weather dashboard image — img_get_started_dashboard.png
          // Figma node 10:258: 308×336 positioned at left:17, top:19
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: const CommonIcon(
                path: AppAssets.imgGetStartedDashboard,
                width: 260,
                height: 240,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Floating "Feels like" card — Figma: 130×66 at left:188, top:284
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.getStartedButton.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getStartedButton.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.thermostat_rounded,
                    size: 26,
                    color: AppColors.locationButton,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Feels like',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          height: 1.33,
                        ),
                      ),
                      Text(
                        '24°C',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.43,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Top-right decorative SVG — ic_get_started_deco_star.svg
          // Figma node 10:254: 55×55 at left:255, top:32
          const Positioned(
            top: 20,
            right: 12,
            child: CommonIcon(
              path: AppAssets.icGetStartedDecoStar,
              width: 44,
              height: 44,
            ),
          ),

          // Bottom-left decorative SVG — ic_get_started_deco_cloud.svg
          // Figma node 10:256: 30×26 at left:32, top:300
          const Positioned(
            bottom: 24,
            left: 16,
            child: CommonIcon(
              path: AppAssets.icGetStartedDecoCloud,
              width: 30,
              height: 26,
            ),
          ),
        ],
      ),
    );
  }
}
