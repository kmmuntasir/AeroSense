import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/onboarding_controller.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
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
          ),
        );
      }),
    );
  }
}

class _OnboardingPrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OnboardingPrimaryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 342,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: Colors.white),
        label: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class _OnboardingSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OnboardingSecondaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 1 – Location
// ---------------------------------------------------------------------------

class _LocationPage extends StatelessWidget {
  const _LocationPage();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Skip button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: controller.onEnterManually,
              child: Text(
                'Skip',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Illustration
          Center(
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.locationButton.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                size: 80,
                color: AppColors.locationButton,
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            'Where in the world\nare you?',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // Body
          Text(
            'Allow AeroSense to access your location for accurate, real-time weather updates tailored to where you are.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: AppColors.textBody,
              height: 1.5,
            ),
          ),
          const Spacer(),
          // Primary button
          Center(
            child: _OnboardingPrimaryButton(
              label: 'Enable Location',
              icon: Icons.my_location_rounded,
              color: AppColors.locationButton,
              onTap: controller.onEnableLocation,
            ),
          ),
          const SizedBox(height: 16),
          // Secondary button
          Center(
            child: _OnboardingSecondaryButton(
              label: 'Enter location manually',
              onTap: controller.onEnterManually,
            ),
          ),
          const SizedBox(height: 24),
          // Progress dots
          const Center(child: _OnboardingProgressDots(activeIndex: 0)),
          const SizedBox(height: 32),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Progress dots at top
          const Center(child: _OnboardingProgressDots(activeIndex: 1)),
          const SizedBox(height: 40),
          // Illustration
          Center(
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFA726).withValues(alpha: 0.25),
                    const Color(0xFFFFEB3B).withValues(alpha: 0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_rounded,
                size: 80,
                color: Color(0xFFF97316),
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            'Stay ahead of\nthe storm',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // Body
          Text(
            'Get timely weather alerts and daily forecasts so you\'re never caught off guard. We\'ll only notify you when it matters.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const Spacer(),
          // Primary button
          Center(
            child: _OnboardingPrimaryButton(
              label: 'Turn on Notifications',
              icon: Icons.notifications_active_rounded,
              color: AppColors.notificationButton,
              onTap: controller.onEnableNotifications,
            ),
          ),
          const SizedBox(height: 16),
          // Secondary button
          Center(
            child: _OnboardingSecondaryButton(
              label: 'Maybe later',
              onTap: controller.onMaybeLater,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Progress dots at top
          const Center(child: _OnboardingProgressDots(activeIndex: 2)),
          const SizedBox(height: 40),
          // Illustration
          Center(
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.getStartedButton.withValues(alpha: 0.15),
                    AppColors.locationButton.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.wb_sunny_rounded,
                    size: 72,
                    color: AppColors.getStartedButton,
                  ),
                  // Floating card decoration
                  Positioned(
                    bottom: 16,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Feels like 24°C',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            'Your personal weather,\nyour way',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // Body
          Text(
            'AeroSense gives you a beautiful, at-a-glance view of today\'s weather, 5-day forecasts, and air quality — all in one place.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: AppColors.textBody,
              height: 1.5,
            ),
          ),
          const Spacer(),
          // Primary button
          Center(
            child: _OnboardingPrimaryButton(
              label: 'Get Started',
              icon: Icons.arrow_forward_rounded,
              color: AppColors.getStartedButton,
              onTap: controller.onGetStarted,
            ),
          ),
          const SizedBox(height: 16),
          // Secondary button
          Center(
            child: _OnboardingSecondaryButton(
              label: 'Skip setup for now',
              onTap: controller.onSkipSetup,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
