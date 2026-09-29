import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ledgerly_logo.dart';
import '../../core/widgets/smooth_page_route.dart';
import '../welcome/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (mounted) {
      _navigateToWelcome();
    }
  }

  void _navigateToWelcome() {
    Navigator.of(context).pushReplacement(
      SmoothPageRoute(
        page: const WelcomeScreen(),
        transitionType: SmoothTransitionType.fadeThrough,
        duration: const Duration(milliseconds: 550),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: GestureDetector(
        onTap: _navigateToWelcome,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient Green Radial Glow (Flash Screen part-3)
            Positioned(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentGreen.withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 800.ms)
                  .scale(
                    begin: const Offset(0.6, 0.6),
                    end: const Offset(1.2, 1.2),
                    duration: 1200.ms,
                    curve: Curves.easeOutBack,
                  ),
            ),

            // Centered Logo & Brand Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Book Logo with Rupee & Checkmark (Flash Screen part-2)
                  const LedgerlyLogo(size: 110)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(
                        begin: const Offset(0.7, 0.7),
                        end: const Offset(1.0, 1.0),
                        duration: 650.ms,
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: 18),

                  // Horizontal Green Accent Line (Flash Screen end)
                  Container(
                    height: 3.5,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColors.accentGreenBright,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentGreenBright.withOpacity(0.55),
                          blurRadius: 10,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 650.ms, duration: 400.ms)
                      .scaleX(
                        begin: 0.0,
                        end: 1.0,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: 14),

                  // Brand Title "Ledgerly" (Flash Screen end)
                  const Text(
                    'Ledgerly',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      fontFamily: 'sans-serif',
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 850.ms, duration: 500.ms)
                      .slideY(
                        begin: 0.25,
                        end: 0.0,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ],
              ),
            ),

            // Subtle tap indicator at bottom
            Positioned(
              bottom: 36,
              child: Text(
                'Tap anywhere to skip',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 12,
                ),
              ).animate().fadeIn(delay: 1500.ms),
            ),
          ],
        ),
      ),
    );
  }
}
