import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction_model.dart';
import '../data/mock_data.dart';

class TransactionNotifier extends Notifier<List<TransactionModel>> {
  @override
  List<TransactionModel> build() {
    return MockData.initialTransactions;
  }

  void addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
    required DateTime date,
    required String paymentMode,
    String? note,
    String? transferTo,
  }) {
    final newTx = TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: title.isEmpty ? category : title,
      amount: amount,
      type: type,
      category: category,
      date: date,
      paymentMode: paymentMode,
      note: note,
      transferTo: transferTo,
    );

    state = [newTx, ...state];
  }

  void deleteTransaction(String id) {
    state = state.where((tx) => tx.id != id).toList();
  }
}

final transactionProvider =
    NotifierProvider<TransactionNotifier, List<TransactionModel>>(() {
  return TransactionNotifier();
});

// Computed spending values
final monthlySpendingProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionProvider);
  return transactions
      .where((t) => t.isExpense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final monthlyIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionProvider);
  return transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);
});
