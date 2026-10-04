import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/budget_model.dart';
import '../data/mock_data.dart';

class BudgetNotifier extends Notifier<MonthlyBudget> {
  static const List<String> availableMonths = [
    'January 2026',
    'February 2026',
    'March 2026',
    'April 2026',
    'May 2026',
    'June 2026',
  ];

  @override
  MonthlyBudget build() {
    return MockData.initialMonthlyBudget;
  }

  void updateTotalBudget(double amount) {
    state = state.copyWith(totalBudget: amount);
  }

  void setMonth(String newMonth) {
    state = state.copyWith(month: newMonth);
  }

  void nextMonth() {
    final idx = availableMonths.indexOf(state.month);
    if (idx != -1 && idx < availableMonths.length - 1) {
      state = state.copyWith(month: availableMonths[idx + 1]);
    } else if (idx == -1) {
      state = state.copyWith(month: availableMonths.first);
    }
  }

  void previousMonth() {
    final idx = availableMonths.indexOf(state.month);
    if (idx > 0) {
      state = state.copyWith(month: availableMonths[idx - 1]);
    }
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

  void addExpenseToCategory(String categoryName, double amount) {
    bool matched = false;
    final updatedList = state.categories.map((c) {
      final nameLower = c.name.toLowerCase();
      final catLower = categoryName.toLowerCase();
      if (nameLower == catLower ||
          (nameLower.contains('food') && catLower.contains('dining')) ||
          (nameLower.contains('dining') && catLower.contains('food')) ||
          nameLower.contains(catLower) ||
          catLower.contains(nameLower)) {
        matched = true;
        return c.copyWith(spent: c.spent + amount);
      }
      return c;
    }).toList();

    // If no matching category found, add to first category or create one
    if (!matched && updatedList.isNotEmpty) {
      final first = updatedList.first;
      updatedList[0] = first.copyWith(spent: first.spent + amount);
    }

    state = state.copyWith(categories: updatedList);
  }

  void removeExpenseFromCategory(String categoryName, double amount) {
    final updatedList = state.categories.map((c) {
      final nameLower = c.name.toLowerCase();
      final catLower = categoryName.toLowerCase();
      if (nameLower == catLower ||
          (nameLower.contains('food') && catLower.contains('dining')) ||
          (nameLower.contains('dining') && catLower.contains('food')) ||
          nameLower.contains(catLower) ||
          catLower.contains(nameLower)) {
        return c.copyWith(spent: (c.spent - amount).clamp(0.0, double.infinity));
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
