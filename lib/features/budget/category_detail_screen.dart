import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/animated_currency_counter.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;
  final double budgetAmount;
  final double spentAmount;

  const CategoryDetailScreen({
    super.key,
    required this.categoryName,
    this.budgetAmount = 15000,
    this.spentAmount = 12450,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (budgetAmount - spentAmount).clamp(0.0, double.infinity);
    final percentage = budgetAmount > 0 ? (spentAmount / budgetAmount).clamp(0.0, 1.0) : 0.0;
    final percentageInt = (percentage * 100).round();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          categoryName,
          style: AppTypography.headingMedium.copyWith(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Overview Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Spent this Month',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedCurrencyCounter(
                            amount: spentAmount,
                            style: AppTypography.headingLarge.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.catFun,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Budget: ${Formatters.currency(budgetAmount, showDecimals: false)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$percentageInt% used',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.accentGreenBright,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 8,
                      color: const Color(0xFFE2E8F0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: constraints.maxWidth * percentage,
                              decoration: BoxDecoration(
                                color: const Color(0xFF047857),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ).animate().scaleX(
                                  begin: 0,
                                  end: 1,
                                  duration: 700.ms,
                                  curve: Curves.easeOutCubic,
                                ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      '${Formatters.currency(remaining, showDecimals: false)} remaining for April',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms),

            const SizedBox(height: 20),

            // Two Metric Cards (Avg. per day & Frequent Day)
            Row(
              children: [
                // Dark Card: Avg. per day
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.trending_up_rounded,
                          color: Colors.white70,
                          size: 24,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Avg. per day',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '₹415',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Light Card: Frequent Day
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Frequent Day',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Friday',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 28),

            // Recent Activity Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: AppTypography.headingSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'See All',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.accentGreenBright,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 14),

            // Activity Items matching Dining Frame
            _buildActivityItem('Blue Tokai Coffee', '14 Apr 2024 • 09:20 AM', '340.00', Icons.local_cafe_outlined),
            _buildActivityItem('Pizza Hut', '12 Apr 2024 • 08:45 PM', '1,290.00', Icons.local_pizza_outlined),
            _buildActivityItem('Burger King', '10 Apr 2024 • 01:15 PM', '560.00', Icons.lunch_dining_outlined),
            _buildActivityItem('The Social', '08 Apr 2024 • 11:30 PM', '4,800.00', Icons.wine_bar_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String amount, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '-₹$amount',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
