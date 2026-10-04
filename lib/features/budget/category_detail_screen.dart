import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/animated_currency_counter.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../data/models/transaction_model.dart';
import '../../state/budget_state.dart';
import '../../state/transaction_state.dart';
import '../transactions/add_transaction_modal.dart';

class CategoryDetailScreen extends ConsumerWidget {
  final String categoryName;
  final double budgetAmount;
  final double spentAmount;
  final IconData? categoryIcon;
  final Color? categoryColor;

  const CategoryDetailScreen({
    super.key,
    required this.categoryName,
    this.budgetAmount = 15000,
    this.spentAmount = 12450,
    this.categoryIcon,
    this.categoryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(budgetProvider);
    final allTransactions = ref.watch(transactionProvider);

    // Find category in budget provider if present
    final matchedCat = budget.categories.cast<dynamic>().firstWhere(
          (c) =>
              c.name.toLowerCase() == categoryName.toLowerCase() ||
              (c.name.toLowerCase().contains('food') && categoryName.toLowerCase().contains('dining')) ||
              (c.name.toLowerCase().contains('dining') && categoryName.toLowerCase().contains('food')),
          orElse: () => null,
        );

    final effectiveBudget = matchedCat != null ? (matchedCat.allocated as double) : budgetAmount;
    final effectiveSpent = matchedCat != null ? (matchedCat.spent as double) : spentAmount;
    final effectiveColor = categoryColor ?? (matchedCat != null ? (matchedCat.color as Color) : AppColors.catDining);
    final effectiveIcon = categoryIcon ?? (matchedCat != null ? (matchedCat.icon as IconData) : Icons.restaurant_rounded);

    final remaining = (effectiveBudget - effectiveSpent).clamp(0.0, double.infinity);
    final percentage = effectiveBudget > 0 ? (effectiveSpent / effectiveBudget).clamp(0.0, 1.0) : 0.0;
    final percentageInt = (percentage * 100).round();

    // Filter transactions for this category
    final categoryTransactions = allTransactions.where((tx) {
      final txCat = tx.category.toLowerCase();
      final cat = categoryName.toLowerCase();
      return txCat == cat ||
          (txCat.contains('food') && cat.contains('dining')) ||
          (txCat.contains('dining') && cat.contains('food')) ||
          txCat.contains(cat) ||
          cat.contains(txCat);
    }).toList();

    // Calculate metrics
    final avgPerDay = (effectiveSpent / 30.0).round();
    final frequentDay = _calculateFrequentDay(categoryTransactions);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.textPrimary),
            tooltip: 'Add Transaction',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddTransactionModal(),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Overview Card matching Dining Frame
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
                            amount: effectiveSpent,
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
                          color: effectiveColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          effectiveIcon,
                          color: effectiveColor,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Budget: ${Formatters.currency(effectiveBudget, showDecimals: false)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$percentageInt% used',
                        style: AppTypography.bodySmall.copyWith(
                          color: percentage > 0.95 ? AppColors.errorRed : AppColors.accentGreenBright,
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
                                color: percentage > 0.95 ? AppColors.errorRed : const Color(0xFF047857),
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
                      '${Formatters.currency(remaining, showDecimals: false)} remaining for ${budget.month.split(' ').first}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
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
                        Text(
                          '₹$avgPerDay',
                          style: const TextStyle(
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
                          frequentDay,
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
                  '${categoryTransactions.length} Items',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 14),

            // Activity Items: Dynamic from categoryTransactions
            if (categoryTransactions.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    Icon(effectiveIcon, size: 40, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      'No activity recorded for $categoryName yet',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    BouncingButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const AddTransactionModal(),
                        );
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(12),
                      child: const Text('Add First Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ...categoryTransactions.map((tx) {
                return _buildActivityTile(context, ref, tx, effectiveIcon);
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(BuildContext context, WidgetRef ref, TransactionModel tx, IconData defaultIcon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        onTap: () => _showActivityDetailSheet(context, ref, tx),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: tx.categoryBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(tx.categoryIcon, color: tx.categoryColor, size: 22),
        ),
        title: Text(
          tx.title,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${Formatters.relativeDate(tx.date)} • ${tx.paymentMode}',
          style: AppTypography.bodySmall,
        ),
        trailing: Text(
          '-${Formatters.currency(tx.amount)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  void _showActivityDetailSheet(BuildContext context, WidgetRef ref, TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tx.categoryBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(tx.categoryIcon, color: tx.categoryColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx.title, style: AppTypography.headingSmall),
                      Text('${tx.category} • ${tx.paymentMode}', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
                Text(
                  '-${Formatters.currency(tx.amount)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.borderLight),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                Text(Formatters.dateLong(tx.date), style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            if (tx.note != null && tx.note!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Note', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                  Text(tx.note!, style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ],
            const SizedBox(height: 24),
            BouncingButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                if (tx.isExpense) {
                  ref.read(budgetProvider.notifier).removeExpenseFromCategory(tx.category, tx.amount);
                }
                ref.read(transactionProvider.notifier).deleteTransaction(tx.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted "${tx.title}"')),
                );
              },
              color: Colors.white,
              border: Border.all(color: AppColors.errorRed, width: 1.5),
              borderRadius: BorderRadius.circular(14),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline_rounded, color: AppColors.errorRed, size: 18),
                  SizedBox(width: 6),
                  Text('Delete Expense', style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateFrequentDay(List<TransactionModel> txs) {
    if (txs.isEmpty) return 'Friday';
    final Map<int, int> weekdayCounts = {};
    for (var tx in txs) {
      weekdayCounts[tx.date.weekday] = (weekdayCounts[tx.date.weekday] ?? 0) + 1;
    }
    int bestDay = 5; // Friday default
    int maxCount = -1;
    weekdayCounts.forEach((day, count) {
      if (count > maxCount) {
        maxCount = count;
        bestDay = day;
      }
    });

    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[(bestDay - 1).clamp(0, 6)];
  }
}
