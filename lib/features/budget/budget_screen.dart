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
import 'edit_budget_screen.dart';
import 'category_detail_screen.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(budgetProvider);

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
              // Title: Budget
              Text(
                'Budget',
                style: AppTypography.headingLarge.copyWith(fontSize: 24),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 16),

              // Month Selector Bar: < [calendar] April 2026 >
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: AppColors.accentGreenBright,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          budget.month,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 20),

              // Dark Navy Monthly Budget Card with Radial Ring
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'TOTAL MONTHLY BUDGET',
                      style: AppTypography.labelUppercase.copyWith(
                        color: Colors.white.withOpacity(0.6),
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedCurrencyCounter(
                      amount: budget.totalBudget,
                      showDecimals: false,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Spent vs Remaining Mini Cards
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'SPENT',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.55),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  Formatters.currency(budget.totalSpent, showDecimals: false),
                                  style: const TextStyle(
                                    color: AppColors.accentGreenBright,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'REMAINING',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.55),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  Formatters.currency(budget.totalRemaining, showDecimals: false),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Animated Radial Circular Progress Gauge
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(140, 140),
                            painter: _RadialRingPainter(
                              progress: budget.percentageUsed,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${budget.percentageUsedInt}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'USED',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.65),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.08, end: 0),

              const SizedBox(height: 20),

              // "Edit Budget" Button (Right-aligned or full-width)
              Align(
                alignment: Alignment.centerRight,
                child: BouncingButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      SmoothPageRoute(
                        page: const EditBudgetScreen(),
                        transitionType: SmoothTransitionType.slideUp,
                      ),
                    );
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  color: const Color(0xFF047857),
                  borderRadius: BorderRadius.circular(14),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Edit Budget',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 24),

              // Category Budgets Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category Budgets',
                    style: AppTypography.headingSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'View All',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.accentGreenBright,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 250.ms),

              const SizedBox(height: 14),

              // Category Budget Cards List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: budget.categories.length,
                itemBuilder: (context, index) {
                  final cat = budget.categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BouncingButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          SmoothPageRoute(
                            page: CategoryDetailScreen(
                              categoryName: cat.name,
                              budgetAmount: cat.allocated,
                              spentAmount: cat.spent,
                            ),
                            transitionType: SmoothTransitionType.slideRight,
                          ),
                        );
                      },
                      padding: const EdgeInsets.all(18),
                      color: Colors.white,
                      border: Border.all(color: AppColors.borderLight),
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: cat.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(cat.icon, color: cat.color, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cat.name,
                                      style: AppTypography.titleSmall.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${Formatters.currency(cat.spent, showDecimals: false)} / ${Formatters.currency(cat.allocated, showDecimals: false)}',
                                      style: AppTypography.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${cat.percentageInt}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: cat.percentage,
                              minHeight: 6,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 8),

              // Dashed "+ Add New Category" Card
              BouncingButton(
                onPressed: () {
                  _showAddCategoryDialog(context, ref);
                },
                padding: const EdgeInsets.symmetric(vertical: 24),
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.borderLight,
                  width: 1.5,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add, color: AppColors.textPrimary, size: 22),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Add New Category',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
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

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Add New Category', style: AppTypography.headingSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Budget Amount (₹)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          BouncingButton(
            onPressed: () {
              final name = nameController.text.trim();
              final amount = double.tryParse(amountController.text) ?? 5000.0;
              if (name.isNotEmpty) {
                ref.read(budgetProvider.notifier).addNewCategory(
                      name: name,
                      subtitle: 'Custom Goal',
                      allocated: amount,
                      icon: Icons.category_outlined,
                      color: AppColors.catRent,
                    );
              }
              Navigator.of(ctx).pop();
            },
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: AppColors.primaryNavy,
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _RadialRingPainter extends CustomPainter {
  final double progress;

  _RadialRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 14.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Glowing Progress Arc
    final arcPaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadialRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
