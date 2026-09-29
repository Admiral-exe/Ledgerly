import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum TransactionType { income, expense, transfer }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String paymentMode;
  final String? note;
  final String? transferTo;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.paymentMode,
    this.note,
    this.transferTo,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get isTransfer => type == TransactionType.transfer;

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'food':
      case 'food & dining':
      case 'dining':
        return AppColors.catDining;
      case 'transport':
      case 'travel':
        return AppColors.catTravel;
      case 'rent':
      case 'housing':
        return AppColors.catRent;
      case 'shopping':
        return AppColors.catShopping;
      case 'bills':
        return AppColors.catBills;
      case 'salary':
        return AppColors.catSalary;
      case 'invest':
        return AppColors.catInvest;
      case 'gift':
        return AppColors.catGift;
      case 'bonus':
        return AppColors.catBonus;
      case 'fun':
        return AppColors.catFun;
      case 'health':
        return AppColors.catHealth;
      default:
        return AppColors.catOther;
    }
  }

  Color get categoryBgColor {
    switch (category.toLowerCase()) {
      case 'food':
      case 'food & dining':
      case 'dining':
        return AppColors.catDiningBg;
      case 'transport':
      case 'travel':
        return AppColors.catTravelBg;
      case 'rent':
      case 'housing':
        return AppColors.catRentBg;
      case 'shopping':
        return AppColors.catShoppingBg;
      case 'bills':
        return AppColors.catBillsBg;
      case 'salary':
        return AppColors.catSalaryBg;
      case 'invest':
        return AppColors.catInvestBg;
      case 'gift':
        return AppColors.catGiftBg;
      case 'bonus':
        return AppColors.catBonusBg;
      case 'fun':
        return AppColors.catFunBg;
      case 'health':
        return AppColors.catHealthBg;
      default:
        return AppColors.catOtherBg;
    }
  }

  IconData get categoryIcon {
    switch (category.toLowerCase()) {
      case 'food':
      case 'food & dining':
      case 'dining':
        return Icons.restaurant_rounded;
      case 'transport':
      case 'travel':
        return Icons.directions_car_rounded;
      case 'rent':
      case 'housing':
        return Icons.home_rounded;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'salary':
        return Icons.payments_outlined;
      case 'invest':
        return Icons.trending_up_rounded;
      case 'gift':
        return Icons.card_giftcard_rounded;
      case 'bonus':
        return Icons.volunteer_activism_rounded;
      case 'fun':
        return Icons.movie_outlined;
      case 'health':
        return Icons.medical_services_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type.name,
        'category': category,
        'date': date.toIso8601String(),
        'paymentMode': paymentMode,
        'note': note,
        'transferTo': transferTo,
      };

  factory TransactionModel.fromMap(Map<String, dynamic> map) => TransactionModel(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        amount: (map['amount'] as num).toDouble(),
        type: TransactionType.values.byName(map['type'] ?? 'expense'),
        category: map['category'] ?? 'Other',
        date: DateTime.parse(map['date']),
        paymentMode: map['paymentMode'] ?? 'Bank Account',
        note: map['note'],
        transferTo: map['transferTo'],
      );
}
