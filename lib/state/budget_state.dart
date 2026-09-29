import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/budget_model.dart';
import '../data/mock_data.dart';

class BudgetNotifier extends Notifier<MonthlyBudget> {
  @override
  MonthlyBudget build() {
    return MockData.initialMonthlyBudget;
  }

  void updateTotalBudget(double amount) {
    state = state.copyWith(totalBudget: amount);
  }

  void updateCategoryAllocation(String categoryId, double newAllocation) {
    final updatedList = state.categories.map((c) {
      if (c.id == categoryId) {
        return c.copyWith(allocated: newAllocation);
      }
      return c;
    }).toList();

    state = state.copyWith(categories: updatedList);
  }

  void autoApplyRecommendations() {
    final updatedList = state.categories.map((c) {
      return c.copyWith(allocated: c.recommended);
    }).toList();

    state = state.copyWith(
      totalBudget: 55000.0,
      categories: updatedList,
    );
  }

  void addNewCategory({
    required String name,
    required String subtitle,
    required double allocated,
    required IconData icon,
    required Color color,
  }) {
    final newCat = CategoryBudget(
      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      subtitle: subtitle,
      allocated: allocated,
      spent: 0.0,
      recommended: allocated * 1.1,
      icon: icon,
      color: color,
    );

    state = state.copyWith(
      totalBudget: state.totalBudget + allocated,
      categories: [...state.categories, newCat],
    );
  }
}

final budgetProvider = NotifierProvider<BudgetNotifier, MonthlyBudget>(() {
  return BudgetNotifier();
});
