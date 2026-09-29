import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/bouncing_button.dart';

class BudgetSuccessScreen extends StatelessWidget {
  final double newBudget;

  const BudgetSuccessScreen({
    super.key,
    required this.newBudget,
  });

  @override
  Widget build(BuildContext context) {
    final dailyLimit = newBudget / 30.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated Celebration Check Card with Glow
              Stack(
                alignment: Alignment.center,
                children: [
                  // Glow background
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accentGreenBright.withOpacity(0.25),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Card with circular check
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: const BoxDecoration(
                            color: Color(0xFF047857),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 90,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: const Color(0xFF047857),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(),

              const SizedBox(height: 36),

              // "Budget Updated Successfully!"
              Text(
                'Budget Updated\nSuccessfully!',
                textAlign: TextAlign.center,
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  height: 1.25,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0.0),

              const SizedBox(height: 14),

              Text(
                'Your new monthly budget of\n${Formatters.currency(newBudget, showDecimals: false)} has been set.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 28),

              // Daily Limit Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'DAILY LIMIT',
                      style: AppTypography.labelUppercase.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Formatters.currency(dailyLimit, showDecimals: false),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),

              const Spacer(flex: 3),

              // "Back to Budget ->" CTA
              BouncingButton(
                onPressed: () => Navigator.of(context).pop(),
                color: Colors.black,
                height: 56,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Back to Budget',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                  ],
                ),
              ).animate().fadeIn(delay: 450.ms),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
