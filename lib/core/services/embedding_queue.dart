import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/transaction_model.dart';
import 'local_vector_store.dart';
import 'rag_ai_service.dart';

/// Non-blocking background worker that manages vector embedding creation and offline synchronization.
class EmbeddingQueue {
  static final EmbeddingQueue _instance = EmbeddingQueue._internal();
  factory EmbeddingQueue() => _instance;
  EmbeddingQueue._internal();

  bool _isProcessing = false;
  final List<TransactionModel> _pendingQueue = [];

  /// Instantly enqueues a transaction for vector embedding without blocking the UI thread.
  void enqueue(TransactionModel tx) {
    // 1. Immediately create a local record with deterministic vector and isEmbedded: false
    // This guarantees the transaction is searchable locally in 0ms even if offline.
    final noteSuffix = (tx.note != null && tx.note!.trim().isNotEmpty) ? ' - ${tx.note!.trim()}' : '';
    final text = '${tx.isIncome ? "Income" : "Spent"} ₹${tx.amount.toStringAsFixed(0)} on ${tx.title}$noteSuffix (${tx.category}) via ${tx.paymentMode}';

    final localDoc = VectorDocument(
      id: tx.id,
      text: text,
      vector: LocalVectorStore.deterministicEmbed(
        '${tx.title} ${tx.category} ${tx.note ?? ""} ${tx.isIncome ? "Income" : "Expense"}',
      ),
      metadata: {
        'amount': tx.amount,
        'category': tx.category,
        'type': tx.type.name,
        'date': tx.date.toIso8601String(),
        'title': tx.title,
        'note': tx.note,
      },
      isEmbedded: false,
    );

    LocalVectorStore().upsert(localDoc);

    // 2. Add to background worker queue to fetch high-dimensional Gemini embeddings
    _pendingQueue.add(tx);
    _processQueueAsync();
  }

  /// Batch enqueue multiple transactions (e.g. initial mock data or Excel imports).
  void enqueueBatch(List<TransactionModel> transactions) {
    for (final tx in transactions) {
      enqueue(tx);
    }
  }

  /// Clears any pending queue tasks.
  void clear() {
    _pendingQueue.clear();
  }

  /// Triggers an asynchronous queue processing run.
  void _processQueueAsync() {
    if (_isProcessing || _pendingQueue.isEmpty) return;

    Future.microtask(() async {
      _isProcessing = true;
      try {
        while (_pendingQueue.isNotEmpty) {
          final tx = _pendingQueue.removeAt(0);
          final noteSuffix = (tx.note != null && tx.note!.trim().isNotEmpty) ? ' - ${tx.note!.trim()}' : '';
          final text = '${tx.isIncome ? "Income" : "Spent"} ₹${tx.amount.toStringAsFixed(0)} on ${tx.title}$noteSuffix (${tx.category}) via ${tx.paymentMode}';

          try {
            // Call Gemini embedding API directly from Flutter
            final vector = await RAGAIService().generateEmbedding(text);
            if (vector != null && vector.isNotEmpty) {
              final updatedDoc = VectorDocument(
                id: tx.id,
                text: text,
                vector: vector,
                metadata: {
                  'amount': tx.amount,
                  'category': tx.category,
                  'type': tx.type.name,
                  'date': tx.date.toIso8601String(),
                  'title': tx.title,
                  'note': tx.note,
                },
                isEmbedded: true,
              );
              await LocalVectorStore().upsert(updatedDoc);
              if (kDebugMode) {
                print('[EmbeddingQueue] Successfully indexed "${tx.title}" with Gemini embedding.');
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print('[EmbeddingQueue] Offline or API error for "${tx.title}", kept local fallback: $e');
            }
          }
        }
      } finally {
        _isProcessing = false;
      }
    });
  }

  /// Flushes any unembedded transactions that were saved while the device was offline.
  Future<void> flushUnembedded() async {
    final unembedded = LocalVectorStore().getUnembeddedDocuments();
    if (unembedded.isEmpty) return;

    if (kDebugMode) {
      print('[EmbeddingQueue] Flushing ${unembedded.length} offline transactions...');
    }

    for (final doc in unembedded) {
      try {
        final vector = await RAGAIService().generateEmbedding(doc.text);
        if (vector != null && vector.isNotEmpty) {
          final updated = VectorDocument(
            id: doc.id,
            text: doc.text,
            vector: vector,
            metadata: doc.metadata,
            isEmbedded: true,
          );
          await LocalVectorStore().upsert(updated);
        }
      } catch (_) {
        // Still offline, will retry next time
        break;
      }
    }
  }
}
