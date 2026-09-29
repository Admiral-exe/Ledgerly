import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/animated_currency_counter.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../core/widgets/smooth_page_route.dart';
import '../../state/auth_state.dart';
import '../../state/budget_state.dart';
import '../../state/transaction_state.dart';
import '../notifications/notification_screen.dart';
import '../budget/category_detail_screen.dart';

class HomeDashboardScreen extends ConsumerWidget {
  final VoidCallback onOpenTransactions;
  final VoidCallback onOpenAI;

  const HomeDashboardScreen({
    super.key,
    required this.onOpenTransactions,
    required this.onOpenAI,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final budget = ref.watch(budgetProvider);
    final transactions = ref.watch(transactionProvider);
    final monthlySpending = ref.watch(monthlySpendingProvider);

    // Calculate budget metrics
    final remainingBudget = (budget.totalBudget - monthlySpending).clamp(0.0, double.infinity);
    final percentUsed = budget.totalBudget > 0
        ? (monthlySpending / budget.totalBudget).clamp(0.0, 1.0)
        : 0.0;
    final percentUsedInt = (percentUsed * 100).round();

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
              // Top Bar: Avatar + Name + Notification Bell
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Container(
                        color: const Color(0xFF64748B),
                        alignment: Alignment.center,
                        child: Text(
                          (user?.firstName.isNotEmpty ?? false)
                              ? user!.firstName[0]
                              : 'R',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name
                  Expanded(
                    child: Text(
                      user?.firstName ?? 'Rahul',
                      style: AppTypography.headingLarge.copyWith(
                        fontSize: 22,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),

                  // Notification Bell with badge
                  BouncingButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        SmoothPageRoute(
                          page: const NotificationScreen(),
                          transitionType: SmoothTransitionType.slideRight,
                        ),
                      );
                    },
                    padding: const EdgeInsets.all(10),
                    color: Colors.white,
                    border: Border.all(color: AppColors.borderLight),
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          size: 22,
                          color: AppColors.textPrimary,
                        ),
                        Positioned(
                          right: 1,
                          top: 1,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.errorRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 350.ms),

              const SizedBox(height: 22),

              // Monthly Spending Card (Exact Match to Figma)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MONTHLY SPENDING',
                      style: AppTypography.labelUppercase.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Big Spending Amount
                    AnimatedCurrencyCounter(
                      amount: monthlySpending > 0 ? monthlySpending : 32400.50,
                      style: AppTypography.amountHero.copyWith(
                        fontSize: 34,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Remaining Budget Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'REMAINING BUDGET',
                              style: AppTypography.labelUppercase.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Formatters.currency(
                                remainingBudget > 0 ? remainingBudget : 12590.50,
                              ),
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.accentGreenBright,
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$percentUsedInt% Used',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Smooth Linear Progress Bar
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
                                width: constraints.maxWidth * percentUsed,
                                decoration: BoxDecoration(
                                  color: AppColors.accentGreenBright,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ).animate().scaleX(
                                    begin: 0,
                                    end: 1,
                                    duration: 800.ms,
                                    curve: Curves.easeOutCubic,
                                  ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.08, end: 0),

              const SizedBox(height: 26),

              // Top Categories Section
              Text(
                'Top Categories',
                style: AppTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 14),

              // Horizontal Category Cards
              Row(
                children: [
                  // Food & Dining Card
                  Expanded(
                    child: _buildTopCategoryCard(
                      context: context,
                      title: 'Food & Dining',
                      amount: 8500.00,
                      icon: Icons.restaurant_rounded,
                      color: AppColors.catDining,
                      onTap: () {
                        Navigator.of(context).push(
                          SmoothPageRoute(
                            page: const CategoryDetailScreen(
                              categoryName: 'Dining',
                              budgetAmount: 15000,
                              spentAmount: 12450,
                            ),
                            transitionType: SmoothTransitionType.slideRight,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Transport Card
                  Expanded(
                    child: _buildTopCategoryCard(
                      context: context,
                      title: 'Transport',
                      amount: 4200.00,
                      icon: Icons.directions_car_rounded,
                      color: AppColors.catTravel,
                      onTap: () {
                        Navigator.of(context).push(
                          SmoothPageRoute(
                            page: const CategoryDetailScreen(
                              categoryName: 'Travel',
                              budgetAmount: 5000,
                              spentAmount: 4200,
                            ),
                            transitionType: SmoothTransitionType.slideRight,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 250.ms),

              const SizedBox(height: 28),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: AppTypography.headingSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  GestureDetector(
                    onTap: onOpenTransactions,
                    child: Text(
                      'View All',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 14),

              // Recent Transactions Card List
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: transactions.take(4).length,
                  separatorBuilder: (context, index) => const Divider(
                    color: AppColors.borderLight,
                    height: 1,
                    indent: 68,
                    endIndent: 20,
                  ),
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isPositive = tx.isIncome;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: tx.categoryBgColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          tx.categoryIcon,
                          color: tx.categoryColor,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        tx.title,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        '${tx.category} • ${Formatters.relativeDate(tx.date)}',
                        style: AppTypography.bodySmall,
                      ),
                      trailing: Text(
                        '${isPositive ? '+' : '-'}${Formatters.currency(tx.amount)}',
                        style: TextStyle(
                          color: isPositive
                              ? AppColors.accentGreenBright
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(delay: 350.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopCategoryCard({
    required BuildContext context,
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return BouncingButton(
      onPressed: onTap,
      padding: const EdgeInsets.all(18),
      color: Colors.white,
      border: Border.all(color: AppColors.borderLight),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.currency(amount),
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}
