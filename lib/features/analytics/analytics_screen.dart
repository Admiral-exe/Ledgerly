import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/animated_currency_counter.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../core/widgets/smooth_page_route.dart';
import '../../state/budget_state.dart';
import '../../state/transaction_state.dart';
import '../budget/category_detail_screen.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final budget = ref.watch(budgetProvider);
    final monthlySpending = ref.watch(monthlySpendingProvider);

    // Calculate dynamic category shares
    final totalSpent = monthlySpending > 0 ? monthlySpending : budget.totalSpent;
    final categories = budget.categories;

    // Build slices for donut chart
    final List<Map<String, dynamic>> donutSlices = [];
    if (totalSpent > 0) {
      for (var cat in categories) {
        if (cat.spent > 0) {
          final sweepFraction = cat.spent / totalSpent;
          donutSlices.add({
            'name': cat.name,
            'sweep': sweepFraction,
            'color': cat.color,
            'percent': '${(sweepFraction * 100).round()}%',
          });
        }
      }
    }

    if (donutSlices.isEmpty) {
      donutSlices.add({
        'name': 'Budget Allocation',
        'sweep': 1.0,
        'color': AppColors.primaryNavy,
        'percent': '100%',
      });
    }

    // Sort categories by spent descending
    final sortedCategories = List.of(categories)
      ..sort((a, b) => b.spent.compareTo(a.spent));

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

              // Header Row: Monthly Overview & Month Switcher
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
                  PopupMenuButton<String>(
                    onSelected: (month) {
                      ref.read(budgetProvider.notifier).setMonth(month);
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    itemBuilder: (ctx) => BudgetNotifier.availableMonths
                        .map((m) => PopupMenuItem(value: m, child: Text(m)))
                        .toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Text(
                            budget.month,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 16),

              // Donut Chart Card (Exact Match to Analytics Frame with dynamic data)
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
                            painter: _DynamicDonutChartPainter(slices: donutSlices),
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
                              AnimatedCurrencyCounter(
                                amount: totalSpent,
                                showDecimals: false,
                                style: const TextStyle(
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

                    // Donut Chart Legends Grid
                    Wrap(
                      spacing: 20,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: donutSlices.take(4).map((slice) {
                        return _buildLegendItem(
                          slice['name'] as String,
                          slice['percent'] as String,
                          slice['color'] as Color,
                        );
                      }).toList(),
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
                    _showExportSheetDialog(context, budget, totalSpent);
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

              // Category Breakdown Cards: Dynamic from categories
              ...sortedCategories.map((cat) {
                final catPercent = totalSpent > 0 ? (cat.spent / totalSpent) : 0.0;
                final catPercentStr = '${(catPercent * 100).toStringAsFixed(1)}%';

                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      SmoothPageRoute(
                        page: CategoryDetailScreen(
                          categoryName: cat.name,
                          budgetAmount: cat.allocated,
                          spentAmount: cat.spent,
                          categoryIcon: cat.icon,
                          categoryColor: cat.color,
                        ),
                        transitionType: SmoothTransitionType.slideRight,
                      ),
                    );
                  },
                  child: _buildCategoryBreakdownCard(
                    icon: cat.icon,
                    iconColor: cat.color,
                    iconBg: cat.color.withOpacity(0.12),
                    title: cat.name,
                    subtitle: cat.subtitle,
                    amount: Formatters.currency(cat.spent, showDecimals: false),
                    percent: catPercentStr,
                    progress: catPercent.clamp(0.0, 1.0),
                    progressColor: cat.color,
                  ),
                );
              }),

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
                            sortedCategories.isNotEmpty
                                ? 'Your ${sortedCategories.first.name} spend represents ${(sortedCategories.first.spent / (totalSpent > 0 ? totalSpent : 1) * 100).round()}% of your total outflow. Keep your daily limit in check!'
                                : 'Your spending is 12% lower than last month. Keep it up!',
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
              Text(
                title,
                style: AppTypography.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
                    amount,
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
                      color: progressColor,
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

  void _showExportSheetDialog(BuildContext context, dynamic budget, double totalSpent) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.table_chart_rounded, color: Color(0xFF047857)),
            SizedBox(width: 10),
            Text('Export Balance Sheet', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balance Sheet generated for ${budget.month}:',
              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  _buildBalanceRow('Total Monthly Budget', Formatters.currency(budget.totalBudget)),
                  const Divider(height: 14),
                  _buildBalanceRow('Total Spent Outflow', Formatters.currency(totalSpent)),
                  const Divider(height: 14),
                  _buildBalanceRow(
                    'Net Savings / Surplus',
                    Formatters.currency((budget.totalBudget - totalSpent).clamp(0.0, double.infinity)),
                    isPositive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          BouncingButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Balance sheet CSV downloaded to device'),
                  backgroundColor: Color(0xFF047857),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            width: 120,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: const Color(0xFF047857),
            child: const Text('Download CSV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceRow(String label, String value, {bool isPositive = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isPositive ? AppColors.accentGreenBright : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _DynamicDonutChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> slices;

  _DynamicDonutChartPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 26.0;

    final rect = Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2));

    double startAngle = -math.pi / 2;

    for (var slice in slices) {
      final sweepFraction = (slice['sweep'] as double).clamp(0.0, 1.0);
      final sweepAngle = sweepFraction * 2 * math.pi;
      final paint = Paint()
        ..color = slice['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DynamicDonutChartPainter oldDelegate) => true;
}
