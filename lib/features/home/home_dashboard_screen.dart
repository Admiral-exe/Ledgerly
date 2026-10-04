import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/animated_currency_counter.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../core/widgets/smooth_page_route.dart';
import '../../data/models/transaction_model.dart';
import '../../state/auth_state.dart';
import '../../state/budget_state.dart';
import '../../state/transaction_state.dart';
import '../notifications/notification_screen.dart';
import '../budget/category_detail_screen.dart';
import '../profile/profile_screen.dart';

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

    // Dynamically get the top 2 categories by spent amount
    final sortedCategories = List.of(budget.categories)
      ..sort((a, b) => b.spent.compareTo(a.spent));
    final cat1 = sortedCategories.isNotEmpty ? sortedCategories[0] : null;
    final cat2 = sortedCategories.length > 1 ? sortedCategories[1] : null;

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
              // Top Bar: Avatar + Name (Tappable to Profile) + Notification Bell
              Row(
                children: [
                  // Avatar & Name with tactile feedback
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          SmoothPageRoute(
                            page: const ProfileScreen(),
                            transitionType: SmoothTransitionType.slideRight,
                          ),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello,',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  user?.firstName ?? 'Rahul',
                                  style: AppTypography.headingLarge.copyWith(
                                    fontSize: 22,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
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

                    // Big Spending Amount with animated counter
                    AnimatedCurrencyCounter(
                      amount: monthlySpending,
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
                              Formatters.currency(remainingBudget),
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
                                  color: percentUsed > 0.9
                                      ? AppColors.errorRed
                                      : AppColors.accentGreenBright,
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

              // Horizontal Category Cards (Dynamic from State)
              Row(
                children: [
                  // Top Category 1
                  if (cat1 != null)
                    Expanded(
                      child: _buildTopCategoryCard(
                        context: context,
                        title: cat1.name,
                        amount: cat1.spent,
                        icon: cat1.icon,
                        color: cat1.color,
                        onTap: () {
                          Navigator.of(context).push(
                            SmoothPageRoute(
                              page: CategoryDetailScreen(
                                categoryName: cat1.name,
                                budgetAmount: cat1.allocated,
                                spentAmount: cat1.spent,
                                categoryIcon: cat1.icon,
                                categoryColor: cat1.color,
                              ),
                              transitionType: SmoothTransitionType.slideRight,
                            ),
                          );
                        },
                      ),
                    ),

                  if (cat1 != null && cat2 != null) const SizedBox(width: 14),

                  // Top Category 2
                  if (cat2 != null)
                    Expanded(
                      child: _buildTopCategoryCard(
                        context: context,
                        title: cat2.name,
                        amount: cat2.spent,
                        icon: cat2.icon,
                        color: cat2.color,
                        onTap: () {
                          Navigator.of(context).push(
                            SmoothPageRoute(
                              page: CategoryDetailScreen(
                                categoryName: cat2.name,
                                budgetAmount: cat2.allocated,
                                spentAmount: cat2.spent,
                                categoryIcon: cat2.icon,
                                categoryColor: cat2.color,
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
                    onTap: () => _showAllTransactionsModal(context, ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'View All',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.accentGreenBright,
                          fontWeight: FontWeight.w700,
                        ),
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
                child: transactions.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.receipt_long_outlined, size: 36, color: AppColors.textMuted),
                              const SizedBox(height: 10),
                              Text(
                                'No transactions recorded yet',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
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
                            onTap: () => _showTransactionDetailSheet(context, ref, tx),
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
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

  void _showTransactionDetailSheet(BuildContext context, WidgetRef ref, TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: tx.categoryBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(tx.categoryIcon, color: tx.categoryColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx.title, style: AppTypography.headingSmall),
                      const SizedBox(height: 2),
                      Text('${tx.category} • ${tx.paymentMode}', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
                Text(
                  '${tx.isIncome ? '+' : '-'}${Formatters.currency(tx.amount)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: tx.isIncome ? AppColors.accentGreenBright : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.borderLight),
            const SizedBox(height: 12),
            _buildDetailRow('Date', Formatters.dateLong(tx.date)),
            const SizedBox(height: 10),
            _buildDetailRow('Payment Mode', tx.paymentMode),
            if (tx.note != null && tx.note!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildDetailRow('Note', tx.note!),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: BouncingButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _confirmDeleteTransaction(context, ref, tx);
                    },
                    color: Colors.white,
                    border: Border.all(color: AppColors.errorRed, width: 1.5),
                    borderRadius: BorderRadius.circular(14),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline_rounded, color: AppColors.errorRed, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Delete Transaction',
                          style: TextStyle(
                            color: AppColors.errorRed,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteTransaction(BuildContext context, WidgetRef ref, TransactionModel tx) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Transaction', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete "${tx.title}" of ${Formatters.currency(tx.amount)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              if (tx.isExpense) {
                ref.read(budgetProvider.notifier).removeExpenseFromCategory(tx.category, tx.amount);
              }
              ref.read(transactionProvider.notifier).deleteTransaction(tx.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Transaction "${tx.title}" deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }

  void _showAllTransactionsModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final allTransactions = ref.watch(transactionProvider);
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('All Transactions', style: AppTypography.headingMedium),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.borderLight),
                Expanded(
                  child: allTransactions.isEmpty
                      ? const Center(child: Text('No transactions yet'))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          itemCount: allTransactions.length,
                          separatorBuilder: (context, index) => const Divider(
                            color: AppColors.borderLight,
                            height: 1,
                            indent: 64,
                          ),
                          itemBuilder: (context, index) {
                            final tx = allTransactions[index];
                            final isPositive = tx.isIncome;
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              onTap: () {
                                Navigator.of(ctx).pop();
                                _showTransactionDetailSheet(context, ref, tx);
                              },
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: tx.categoryBgColor,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(tx.categoryIcon, color: tx.categoryColor, size: 22),
                              ),
                              title: Text(tx.title, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                              subtitle: Text('${tx.category} • ${Formatters.relativeDate(tx.date)}', style: AppTypography.bodySmall),
                              trailing: Text(
                                '${isPositive ? '+' : '-'}${Formatters.currency(tx.amount)}',
                                style: TextStyle(
                                  color: isPositive ? AppColors.accentGreenBright : AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
