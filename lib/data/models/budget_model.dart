import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CategoryBudget {
  final String id;
  final String name;
  final String subtitle;
  final double allocated;
  final double spent;
  final double recommended;
  final IconData icon;
  final Color color;

  const CategoryBudget({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.allocated,
    required this.spent,
    required this.recommended,
    required this.icon,
    required this.color,
  });

  double get percentage => allocated > 0 ? (spent / allocated).clamp(0.0, 1.0) : 0.0;
  int get percentageInt => (percentage * 100).round();
  double get remaining => (allocated - spent).clamp(0.0, double.infinity);

  CategoryBudget copyWith({
    String? id,
    String? name,
    String? subtitle,
    double? allocated,
    double? spent,
    double? recommended,
    IconData? icon,
    Color? color,
  }) {
    return CategoryBudget(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      allocated: allocated ?? this.allocated,
      spent: spent ?? this.spent,
      recommended: recommended ?? this.recommended,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }
}

class MonthlyBudget {
  final String month;
  final double totalBudget;
  final List<CategoryBudget> categories;

  const MonthlyBudget({
    required this.month,
    required this.totalBudget,
    required this.categories,
  });

  double get totalSpent => categories.fold(0.0, (sum, item) => sum + item.spent);
  double get totalRemaining => (totalBudget - totalSpent).clamp(0.0, double.infinity);
  double get percentageUsed => totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
  int get percentageUsedInt => (percentageUsed * 100).round();
  double get dailyLimit => (totalBudget / 30.0);

  MonthlyBudget copyWith({
    String? month,
    double? totalBudget,
    List<CategoryBudget>? categories,
  }) {
    return MonthlyBudget(
      month: month ?? this.month,
      totalBudget: totalBudget ?? this.totalBudget,
      categories: categories ?? this.categories,
    );
  }
}
