import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../state/budget_state.dart';
import 'budget_success_screen.dart';

class EditBudgetScreen extends ConsumerStatefulWidget {
  const EditBudgetScreen({super.key});

  @override
  ConsumerState<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends ConsumerState<EditBudgetScreen> {
  late TextEditingController _totalBudgetController;
  final Map<String, TextEditingController> _categoryControllers = {};

  @override
  void initState() {
    super.initState();
    final budget = ref.read(budgetProvider);
    _totalBudgetController = TextEditingController(
      text: budget.totalBudget.toStringAsFixed(0),
    );

    for (var cat in budget.categories) {
      _categoryControllers[cat.id] = TextEditingController(
        text: cat.allocated.toStringAsFixed(0),
      );
    }
  }

  @override
  void dispose() {
    _totalBudgetController.dispose();
    for (var controller in _categoryControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _applyRecommendations() {
    ref.read(budgetProvider.notifier).autoApplyRecommendations();
    final updatedBudget = ref.read(budgetProvider);
    setState(() {
      _totalBudgetController.text = updatedBudget.totalBudget.toStringAsFixed(0);
      for (var cat in updatedBudget.categories) {
        _categoryControllers[cat.id]?.text = cat.allocated.toStringAsFixed(0);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Auto-applied AI budget recommendations (₹55,000)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleSave() {
    final total = double.tryParse(_totalBudgetController.text) ?? 50000.0;
    ref.read(budgetProvider.notifier).updateTotalBudget(total);

    for (var entry in _categoryControllers.entries) {
      final amount = double.tryParse(entry.value.text) ?? 0.0;
      ref.read(budgetProvider.notifier).updateCategoryAllocation(entry.key, amount);
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BudgetSuccessScreen(newBudget: total),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budget = ref.watch(budgetProvider);

    // Calculate total allocated
    double totalAllocated = 0.0;
    for (var controller in _categoryControllers.values) {
      totalAllocated += double.tryParse(controller.text) ?? 0.0;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Budget',
          style: AppTypography.headingMedium.copyWith(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Monthly Budget Input Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL MONTHLY BUDGET',
                    style: AppTypography.labelUppercase.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        '₹',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _totalBudgetController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'ENTER BUDGET AMOUNT',
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppColors.textPrimary, width: 2),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppColors.textPrimary, width: 2),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppColors.accentGreenBright, width: 2.5),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 4),
                            filled: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Recommendation Pill
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Recommended based on your last month: ',
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '₹55,000',
                        style: TextStyle(
                          color: AppColors.accentGreenBright,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _applyRecommendations,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF047857),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'AUTO-APPLY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms),

            const SizedBox(height: 24),

            // Categories Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categories',
                  style: AppTypography.headingSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.textPrimary),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Use "+ Add New Category" from Budget screen'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 10),

            // Category rows matching Budget Frame
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: budget.categories.length,
              itemBuilder: (context, index) {
                final cat = budget.categories[index];
                final controller = _categoryControllers[cat.id];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        child: Icon(cat.icon, color: AppColors.textPrimary, size: 22),
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
                            Text(
                              cat.subtitle,
                              style: AppTypography.bodySmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Rec: ${Formatters.currency(cat.recommended, showDecimals: false)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentGreenBright,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Amount Input Pill
                      Container(
                        width: 110,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              '₹',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  filled: false,
                                ),
                                onChanged: (val) {
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            // Allocation info banner matching Budget Frame
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.accentGreenBright,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You have allocated ${Formatters.currency(totalAllocated, showDecimals: false)} out of your total budget. Your category breakdown matches your goal.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 24),

            // Save Changes CTA
            BouncingButton(
              onPressed: _handleSave,
              color: Colors.black,
              height: 56,
              borderRadius: BorderRadius.circular(16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }
}
