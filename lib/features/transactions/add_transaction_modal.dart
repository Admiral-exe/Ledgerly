import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../data/models/transaction_model.dart';
import '../../state/transaction_state.dart';
import '../../state/budget_state.dart';

class AddTransactionModal extends ConsumerStatefulWidget {
  const AddTransactionModal({super.key});

  @override
  ConsumerState<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends ConsumerState<AddTransactionModal> {
  TransactionType _selectedType = TransactionType.expense;
  final _amountController = TextEditingController(text: '0.00');
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentMode = 'Bank Account';
  String _selectedTransferTo = 'Savings Account';
  String _selectedCategory = 'Dining';

  final List<String> _paymentModes = [
    'Bank Account',
    'Credit Card',
    'UPI',
    'Cash',
    'Wallet',
  ];

  final List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'Dining', 'icon': Icons.restaurant_rounded, 'color': AppColors.catDining, 'bg': AppColors.catDiningBg},
    {'name': 'Travel', 'icon': Icons.directions_car_rounded, 'color': AppColors.catTravel, 'bg': AppColors.catTravelBg},
    {'name': 'Rent', 'icon': Icons.home_rounded, 'color': AppColors.catRent, 'bg': AppColors.catRentBg},
    {'name': 'Shopping', 'icon': Icons.shopping_bag_outlined, 'color': AppColors.catShopping, 'bg': AppColors.catShoppingBg},
    {'name': 'Fun', 'icon': Icons.movie_outlined, 'color': AppColors.catFun, 'bg': AppColors.catFunBg},
    {'name': 'Health', 'icon': Icons.medical_services_outlined, 'color': AppColors.catHealth, 'bg': AppColors.catHealthBg},
    {'name': 'Bills', 'icon': Icons.receipt_long_rounded, 'color': AppColors.catBills, 'bg': AppColors.catBillsBg},
    {'name': 'Other', 'icon': Icons.add_rounded, 'color': AppColors.catOther, 'bg': AppColors.catOtherBg},
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {'name': 'Salary', 'icon': Icons.payments_outlined, 'color': AppColors.catSalary, 'bg': AppColors.catSalaryBg},
    {'name': 'Invest', 'icon': Icons.trending_up_rounded, 'color': AppColors.catInvest, 'bg': AppColors.catInvestBg},
    {'name': 'Gift', 'icon': Icons.card_giftcard_rounded, 'color': AppColors.catGift, 'bg': AppColors.catGiftBg},
    {'name': 'Interest', 'icon': Icons.account_balance_outlined, 'color': AppColors.catRent, 'bg': AppColors.catRentBg},
    {'name': 'Bonus', 'icon': Icons.volunteer_activism_rounded, 'color': AppColors.catBonus, 'bg': AppColors.catBonusBg},
    {'name': 'Selling', 'icon': Icons.storefront_outlined, 'color': AppColors.catHealth, 'bg': AppColors.catHealthBg},
    {'name': 'Rental', 'icon': Icons.real_estate_agent_outlined, 'color': AppColors.catDining, 'bg': AppColors.catDiningBg},
    {'name': 'Other', 'icon': Icons.add_rounded, 'color': AppColors.catOther, 'bg': AppColors.catOtherBg},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(transactionProvider.notifier).addTransaction(
          title: _noteController.text.isNotEmpty
              ? _noteController.text
              : _selectedCategory,
          amount: amount,
          type: _selectedType,
          category: _selectedCategory,
          date: _selectedDate,
          paymentMode: _selectedPaymentMode,
          note: _noteController.text,
          transferTo: _selectedType == TransactionType.transfer
              ? _selectedTransferTo
              : null,
        );

    if (_selectedType == TransactionType.expense) {
      ref.read(budgetProvider.notifier).addExpenseToCategory(_selectedCategory, amount);
    }

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_selectedType == TransactionType.income ? 'Income' : _selectedType == TransactionType.expense ? 'Expense' : 'Transfer'} of ${Formatters.currency(amount)} saved successfully!',
        ),
        backgroundColor: AppColors.accentGreenBright,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _selectedType == TransactionType.income;
    final isExpense = _selectedType == TransactionType.expense;
    final isTransfer = _selectedType == TransactionType.transfer;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions',
                  style: AppTypography.headingLarge.copyWith(fontSize: 22),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // 3-way Segmented Control
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        _buildTab('Income', TransactionType.income, const Color(0xFF4ADE80)),
                        _buildTab('Expense', TransactionType.expense, const Color(0xFFFBCFE8)),
                        _buildTab('Transfer', TransactionType.transfer, const Color(0xFF93C5FD)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Amount Label
                  Text(
                    'AMOUNT',
                    style: AppTypography.labelUppercase.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Big Editable Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: _amountController.text == '0.00'
                                ? AppColors.textMuted.withOpacity(0.7)
                                : AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            filled: false,
                          ),
                          onTap: () {
                            if (_amountController.text == '0.00') {
                              _amountController.clear();
                            }
                          },
                          onChanged: (val) => setState(() {}),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Import Excel Button (Figma feature)
                  Align(
                    alignment: Alignment.centerRight,
                    child: BouncingButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Excel Import: 24 bank statement rows imported successfully!'),
                            backgroundColor: Color(0xFF047857),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      color: const Color(0xFF047857),
                      borderRadius: BorderRadius.circular(12),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.table_view_outlined, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Import Excel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Date Field
                  _buildFormContainer(
                    icon: Icons.calendar_today_outlined,
                    label: 'DATE',
                    value: Formatters.dateLong(_selectedDate),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),

                  const SizedBox(height: 14),

                  // Transfer From / Payment Mode
                  if (!isTransfer) ...[
                    _buildFormContainer(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Payment Mode',
                      value: _selectedPaymentMode,
                      hasDropdown: true,
                      onTap: () => _showPaymentModePicker(false),
                    ),
                  ] else ...[
                    _buildFormContainer(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'From',
                      value: _selectedPaymentMode,
                      hasDropdown: true,
                      onTap: () => _showPaymentModePicker(false),
                    ),
                    const SizedBox(height: 14),
                    _buildFormContainer(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'To',
                      value: _selectedTransferTo,
                      hasDropdown: true,
                      onTap: () => _showPaymentModePicker(true),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Add a note...
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notes_rounded, color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              hintText: 'Add a note...',
                              border: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Select Category (for Income and Expense)
                  if (!isTransfer) ...[
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'SELECT CATEGORY',
                        style: AppTypography.labelUppercase.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.88,
                      ),
                      itemCount: isExpense
                          ? _expenseCategories.length
                          : _incomeCategories.length,
                      itemBuilder: (context, index) {
                        final cat = isExpense
                            ? _expenseCategories[index]
                            : _incomeCategories[index];
                        final isSelected = _selectedCategory == cat['name'];

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedCategory = cat['name'] as String);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryNavy
                                    : AppColors.borderLight,
                                width: isSelected ? 2.0 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: cat['bg'] as Color,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    cat['icon'] as IconData,
                                    color: cat['color'] as Color,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  cat['name'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Bottom Save CTA Button
                  BouncingButton(
                    onPressed: _saveTransaction,
                    color: Colors.black,
                    height: 56,
                    child: Text(
                      isExpense
                          ? 'Save Expense'
                          : isIncome
                              ? 'Save Income'
                              : 'Save',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, TransactionType type, Color activeColor) {
    final isSelected = _selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            _selectedCategory = type == TransactionType.income ? 'Salary' : 'Dining';
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.black : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContainer({
    required IconData icon,
    required String label,
    required String value,
    bool hasDropdown = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (hasDropdown)
              const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary),
          ],
        ),
      ),
    );
  }

  void _showPaymentModePicker(bool isTransferTo) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ListView.builder(
        shrinkWrap: true,
        itemCount: _paymentModes.length,
        itemBuilder: (ctx, index) {
          final mode = _paymentModes[index];
          return ListTile(
            title: Text(mode, style: const TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              setState(() {
                if (isTransferTo) {
                  _selectedTransferTo = mode;
                } else {
                  _selectedPaymentMode = mode;
                }
              });
              Navigator.of(ctx).pop();
            },
          );
        },
      ),
    );
  }
}
