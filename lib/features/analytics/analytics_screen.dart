import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/bouncing_button.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title: Analytics
              Text(
                'Analytics',
                style: AppTypography.headingLarge.copyWith(fontSize: 24),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 16),

              // Header Row: Monthly Overview & Dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ANALYTICS',
                        style: AppTypography.labelUppercase.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Monthly Overview',
                        style: AppTypography.headingSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'October 2023',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 16),

              // Donut Chart Card (Exact Match to Analytics Frame)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                  children: [
                    // Donut Chart
                    SizedBox(
                      width: 190,
                      height: 190,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(190, 190),
                            painter: _DonutChartPainter(),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Total Spent',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '₹ 42,800',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Donut Chart Legends (2 rows of 2 items)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem('Housing', '45%', AppColors.primaryNavy),
                        _buildLegendItem('Transport', '25%', const Color(0xFF047857)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem('Dining', '15%', const Color(0xFF64748B)),
                        _buildLegendItem('Other', '15%', const Color(0xFFCBD5E1)),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 150.ms).scale(curve: Curves.easeOutCubic),

              const SizedBox(height: 18),

              // "Export Balance Sheet" Button
              Align(
                alignment: Alignment.centerRight,
                child: BouncingButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Balance Sheet exported to PDF / CSV successfully!'),
                        backgroundColor: Color(0xFF047857),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  color: const Color(0xFF047857),
                  borderRadius: BorderRadius.circular(14),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.table_chart_outlined, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Export Balance Sheet',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 24),

              // Category Breakdown Header
              Text(
                'Category Breakdown',
                style: AppTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fadeIn(delay: 250.ms),

              const SizedBox(height: 14),

              // Category Breakdown Cards matching Analytics Frame
              _buildCategoryBreakdownCard(
                icon: Icons.home_rounded,
                iconColor: AppColors.catRent,
                iconBg: AppColors.catRentBg,
                title: 'Rent',
                subtitle: 'Mortgage & Utilities',
                amount: '19,260.00',
                percent: '45.0%',
                progress: 0.45,
                progressColor: AppColors.primaryNavy,
              ),

              _buildCategoryBreakdownCard(
                icon: Icons.directions_car_rounded,
                iconColor: AppColors.catTravel,
                iconBg: AppColors.catTravelBg,
                title: 'Travel',
                subtitle: 'Fuel & Transit',
                amount: '10,700.00',
                percent: '25.0%',
                progress: 0.25,
                progressColor: const Color(0xFF047857),
              ),

              _buildCategoryBreakdownCard(
                icon: Icons.restaurant_rounded,
                iconColor: AppColors.catDining,
                iconBg: AppColors.catDiningBg,
                title: 'Dining',
                subtitle: 'Restaurants & Bars',
                amount: '6,420.00',
                percent: '15.0%',
                progress: 0.15,
                progressColor: const Color(0xFF64748B),
              ),

              const SizedBox(height: 16),

              // Dark Smart Insight Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0D1424),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.trending_down_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Smart Insight',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your dining spend is 12% lower than last month. Keep it up!',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 350.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, String percent, Color color) {
    return SizedBox(
      width: 120,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.bodySmall),
              Text(
                percent,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String amount,
    required String percent,
    required double progress,
    required Color progressColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
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
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹$amount',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    percent,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: progressColor == AppColors.primaryNavy
                          ? const Color(0xFF047857)
                          : progressColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 26.0;

    final rect = Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2));

    // 4 Slices matching Analytics Frame:
    // Housing: 45% (Dark navy)
    // Transport: 25% (Green)
    // Dining: 15% (Gray)
    // Other: 15% (Light gray)
    final slices = [
      {'sweep': 0.45, 'color': AppColors.primaryNavy},
      {'sweep': 0.25, 'color': const Color(0xFF047857)},
      {'sweep': 0.15, 'color': const Color(0xFF64748B)},
      {'sweep': 0.15, 'color': const Color(0xFFCBD5E1)},
    ];

    double startAngle = -math.pi / 2;

    for (var slice in slices) {
      final sweepAngle = (slice['sweep'] as double) * 2 * math.pi;
      final paint = Paint()
        ..color = slice['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
