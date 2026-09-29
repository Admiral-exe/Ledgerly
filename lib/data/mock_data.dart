import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'models/user_model.dart';
import 'models/transaction_model.dart';
import 'models/budget_model.dart';

class MockData {
  MockData._();

  static const UserModel initialUser = UserModel(
    id: 'user_01',
    firstName: 'Rahul',
    lastName: 'Sharma',
    email: 'sharahul@ledgerly.in',
    phone: '+91 98765 43210',
    avatarUrl: null,
  );

  static final MonthlyBudget initialMonthlyBudget = MonthlyBudget(
    month: 'April 2026',
    totalBudget: 50000.0,
    categories: [
      CategoryBudget(
        id: 'cat_food',
        name: 'Food',
        subtitle: 'Groceries & Dining',
        allocated: 10000.0,
        spent: 8000.0,
        recommended: 10500.0,
        icon: Icons.restaurant_rounded,
        color: AppColors.catDining,
      ),
      CategoryBudget(
        id: 'cat_travel',
        name: 'Travel',
        subtitle: 'Commute & Trips',
        allocated: 5000.0,
        spent: 3200.0,
        recommended: 4500.0,
        icon: Icons.directions_car_rounded,
        color: AppColors.catTravel,
      ),
      CategoryBudget(
        id: 'cat_rent',
        name: 'Rent',
        subtitle: 'House & Maintenance',
        allocated: 15000.0,
        spent: 15000.0,
        recommended: 22000.0,
        icon: Icons.home_rounded,
        color: AppColors.catRent,
      ),
      CategoryBudget(
        id: 'cat_shopping',
        name: 'Shopping',
        subtitle: 'Apparel & Personal',
        allocated: 6000.0,
        spent: 5250.0,
        recommended: 11000.0,
        icon: Icons.shopping_bag_outlined,
        color: AppColors.catShopping,
      ),
      CategoryBudget(
        id: 'cat_bills',
        name: 'Bills',
        subtitle: 'Utilities & Subs',
        allocated: 14000.0,
        spent: 1000.0,
        recommended: 7000.0,
        icon: Icons.receipt_long_rounded,
        color: AppColors.catBills,
      ),
    ],
  );

  static final List<TransactionModel> initialTransactions = [
    TransactionModel(
      id: 'tx_01',
      title: 'Chroma',
      amount: 1290.00,
      type: TransactionType.expense,
      category: 'Electronics',
      date: DateTime.now(),
      paymentMode: 'Bank Account',
      note: 'USB-C Cable and adapter',
    ),
    TransactionModel(
      id: 'tx_02',
      title: 'Starbucks',
      amount: 650.00,
      type: TransactionType.expense,
      category: 'Food',
      date: DateTime.now().subtract(const Duration(days: 1)),
      paymentMode: 'UPI',
      note: 'Caramel Macchiato & Croissant',
    ),
    TransactionModel(
      id: 'tx_03',
      title: 'Salary Deposit',
      amount: 42000.00,
      type: TransactionType.income,
      category: 'Salary',
      date: DateTime.now().subtract(const Duration(days: 2)),
      paymentMode: 'HDFC Direct',
      note: 'Monthly salary credit',
    ),
    // Additional dining transactions from Dining Frame
    TransactionModel(
      id: 'tx_04',
      title: 'Blue Tokai Coffee',
      amount: 340.00,
      type: TransactionType.expense,
      category: 'Food',
      date: DateTime.now().subtract(const Duration(days: 3)),
      paymentMode: 'UPI',
    ),
    TransactionModel(
      id: 'tx_05',
      title: 'Pizza Hut',
      amount: 1290.00,
      type: TransactionType.expense,
      category: 'Food',
      date: DateTime.now().subtract(const Duration(days: 4)),
      paymentMode: 'Credit Card',
    ),
    TransactionModel(
      id: 'tx_06',
      title: 'Burger King',
      amount: 560.00,
      type: TransactionType.expense,
      category: 'Food',
      date: DateTime.now().subtract(const Duration(days: 5)),
      paymentMode: 'UPI',
    ),
    TransactionModel(
      id: 'tx_07',
      title: 'The Social',
      amount: 4800.00,
      type: TransactionType.expense,
      category: 'Food',
      date: DateTime.now().subtract(const Duration(days: 6)),
      paymentMode: 'Credit Card',
    ),
  ];
}
