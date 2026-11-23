import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/budget_model.dart';
import '../data/mock_data.dart';
import 'auth_state.dart';

class BudgetNotifier extends Notifier<MonthlyBudget> {
  static const List<String> availableMonths = [
    'January 2026',
    'February 2026',
    'March 2026',
    'April 2026',
    'May 2026',
    'June 2026',
  ];

  // Store user-isolated budgets across account switches
  final Map<String, MonthlyBudget> _userBudgets = {
    'user_01': MockData.initialMonthlyBudget,
  };
  String _activeUserId = 'user_01';

  @override
  MonthlyBudget build() {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    if (user != null) {
      _activeUserId = user.id;
      if (auth.isTestAccount) {
        return _userBudgets['user_01'] ?? MockData.initialMonthlyBudget;
      } else {
        // New user starts with clean budget with ₹0 spent
        return _userBudgets[user.id] ?? MockData.cleanMonthlyBudget;
      }
    }

    return MockData.initialMonthlyBudget;
  }

  void updateTotalBudget(double amount) {
    state = state.copyWith(totalBudget: amount);
    _userBudgets[_activeUserId] = state;
  }

  void setMonth(String newMonth) {
    state = state.copyWith(month: newMonth);
    _userBudgets[_activeUserId] = state;
  }

  void nextMonth() {
    final idx = availableMonths.indexOf(state.month);
    if (idx != -1 && idx < availableMonths.length - 1) {
      state = state.copyWith(month: availableMonths[idx + 1]);
    } else if (idx == -1) {
      state = state.copyWith(month: availableMonths.first);
    }
    _userBudgets[_activeUserId] = state;
  }

  void previousMonth() {
    final idx = availableMonths.indexOf(state.month);
    if (idx > 0) {
      state = state.copyWith(month: availableMonths[idx - 1]);
    }
    _userBudgets[_activeUserId] = state;
  }

  void updateCategoryAllocation(String categoryId, double newAllocation) {
    final updatedList = state.categories.map((c) {
      if (c.id == categoryId) {
        return c.copyWith(allocated: newAllocation);
      }
      return c;
    }).toList();

    state = state.copyWith(categories: updatedList);
    _userBudgets[_activeUserId] = state;
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
    _userBudgets[_activeUserId] = state;
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
    _userBudgets[_activeUserId] = state;
  }

  void autoApplyRecommendations() {
    final updatedList = state.categories.map((c) {
      return c.copyWith(allocated: c.recommended);
    }).toList();

    state = state.copyWith(
      totalBudget: 55000.0,
      categories: updatedList,
    );
    _userBudgets[_activeUserId] = state;
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
    _userBudgets[_activeUserId] = state;
  }
}

final budgetProvider = NotifierProvider<BudgetNotifier, MonthlyBudget>(() {
  return BudgetNotifier();
});
