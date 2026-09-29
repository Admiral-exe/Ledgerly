import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../core/widgets/ledgerly_logo.dart';
import '../../core/widgets/smooth_page_route.dart';
import '../auth/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Section: Header & Branding
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 8),
              child: Column(
                children: [
                  const LedgerlyLogo(size: 58, showBadge: true)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        duration: 500.ms,
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: 12),
                  const Text(
                    'LEDGERLY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.2,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ),
            ),

            // Middle Section: 3D Financial Growth Graphic
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ambient backdrop glow
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accentGreen.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // 3D Chart Illustration Stack (Dynamic Vector & Glow)
                  _FinancialGrowthIllustration()
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1.0, 1.0),
                        duration: 700.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ],
              ),
            ),

            // Bottom Section: White Card / Modal Sheet
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 30,
                    offset: Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Headline
                  Text(
                    'Master Your Money',
                    textAlign: TextAlign.center,
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.15, end: 0.0),

                  const SizedBox(height: 14),

                  // Subtitle
                  Text(
                    'Handle your hard-earned money with precision financial tracking built for the modern professional.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 400.ms)
                      .slideY(begin: 0.15, end: 0.0),

                  const SizedBox(height: 32),

                  // "Get Started" CTA Button
                  BouncingButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        SmoothPageRoute(
                          page: const LoginScreen(),
                          transitionType: SmoothTransitionType.slideUp,
                        ),
                      );
                    },
                    color: AppColors.primaryNavy,
                    height: 56,
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 250.ms, duration: 400.ms)
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.0, 1.0),
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: 20),

                  // Terms & Privacy
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'By continuing, you agree to our ',
                        style: AppTypography.bodySmall,
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Terms of Service: Standard financial privacy terms apply.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Text(
                          'Terms',
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(' & ', style: AppTypography.bodySmall),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Privacy Policy: End-to-end local mock encryption active.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Text(
                          'Privacy',
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 350.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialGrowthIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 290,
      height: 200,
      child: CustomPaint(
        painter: _ChartPillarsPainter(),
      ),
    );
  }
}

class _ChartPillarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Base Tablet platform
    final tabletPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final tabletRim = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.05, h * 0.72, w * 0.9, h * 0.16),
      const Radius.circular(16),
    );
    canvas.drawRRect(tabletRim, tabletPaint);

    final screenRim = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.74, w * 0.84, h * 0.10),
      const Radius.circular(10),
    );
    final screenPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(screenRim, screenPaint);

    // Glowing Neon Vertical 3D Bars
    final barData = [
      0.45, 0.35, 0.22, 0.30, 0.40, 0.25, 0.32, 0.55, 0.65, 0.85, 0.70, 0.95
    ];
    final numBars = barData.length;
    final barSpacing = (w * 0.8) / numBars;

    for (int i = 0; i < numBars; i++) {
      final barH = barData[i] * (h * 0.65);
      final barX = (w * 0.1) + (i * barSpacing);
      final barY = (h * 0.72) - barH;

      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            i == numBars - 1
                ? const Color(0xFF22C55E)
                : const Color(0xFF10B981).withOpacity(0.85),
            const Color(0xFF065F46).withOpacity(0.35),
          ],
        ).createShader(Rect.fromLTWH(barX, barY, barSpacing * 0.62, barH));

      final barRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, barY, barSpacing * 0.62, barH),
        const Radius.circular(4),
      );
      canvas.drawRRect(barRRect, barPaint);
    }

    // Glowing Upward Trajectory Curve with Arrow
    final path = Path();
    path.moveTo(w * 0.1, h * 0.62);
    path.quadraticBezierTo(w * 0.45, h * 0.58, w * 0.65, h * 0.42);
    path.quadraticBezierTo(w * 0.75, h * 0.30, w * 0.83, h * 0.12);

    final linePaint = Paint()
      ..color = const Color(0xFF4ADE80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = const Color(0x884ADE80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);

    // Glowing Arrow Head
    final arrowPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.fill;

    final arrowPath = Path();
    arrowPath.moveTo(w * 0.83, h * 0.08);
    arrowPath.lineTo(w * 0.80, h * 0.16);
    arrowPath.lineTo(w * 0.86, h * 0.16);
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
