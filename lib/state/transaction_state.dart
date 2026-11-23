import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/rag_ai_service.dart';
import '../core/services/local_vector_store.dart';
import '../core/services/embedding_queue.dart';
import '../data/models/transaction_model.dart';
import '../data/mock_data.dart';
import 'auth_state.dart';

class TransactionNotifier extends Notifier<List<TransactionModel>> {
  // Store user-isolated transaction lists across account switches
  final Map<String, List<TransactionModel>> _userTransactions = {
    'user_01': MockData.initialTransactions,
  };
  String _activeUserId = 'user_01';

  @override
  List<TransactionModel> build() {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    if (user != null) {
      _activeUserId = user.id;
      if (auth.isTestAccount) {
        final list = _userTransactions['user_01'] ?? MockData.initialTransactions;
        _syncWithLocalRAG(list);
        return list;
      } else {
        // If it's a new account, ensure pre data is NOT shown
        final list = _userTransactions[user.id] ?? <TransactionModel>[];
        if (list.isEmpty) {
          LocalVectorStore().clear();
          EmbeddingQueue().clear();
        } else {
          _syncWithLocalRAG(list);
        }
        return list;
      }
    }

    // Default unauthenticated demo
    _syncWithLocalRAG(MockData.initialTransactions);
    return MockData.initialTransactions;
  }

  void _syncWithLocalRAG(List<TransactionModel> list) {
    Future.microtask(() async {
      try {
        await LocalVectorStore().init();
        if (list.isNotEmpty) {
          await RAGAIService().ingestTransactions(list);
          await EmbeddingQueue().flushUnembedded();
        }
      } catch (_) {}
    });
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

    // Instant UI state update (0ms latency)
    state = [newTx, ...state];
    _userTransactions[_activeUserId] = state;

    // Non-blocking background vector embedding queue
    RAGAIService().ingestTransactions([newTx]);
  }

  void deleteTransaction(String id) {
    state = state.where((tx) => tx.id != id).toList();
    _userTransactions[_activeUserId] = state;
    LocalVectorStore().delete(id);
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
