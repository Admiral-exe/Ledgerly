import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerly/core/services/rag_ai_service.dart';
import 'package:ledgerly/core/services/local_vector_store.dart';
import 'package:ledgerly/core/config/ai_config.dart';
import 'package:ledgerly/data/mock_data.dart';

void main() {
  HttpOverrides.global = null;

  test('Live Gemini Generation & Embedding Connectivity', () async {
    final service = RAGAIService();
    print('Testing Generation Model: ${AIConfig.generationModel}');
    final parsed = await service.parseNaturalTransaction(
      'add expense of 2000, dinner at kismat kathyawadi',
      categories: ['Dining', 'Travel', 'Shopping'],
    );
    print('Parsed action: ${parsed.action}, amount: ${parsed.amount}, category: ${parsed.category}');
    expect(parsed.amount, equals(2000.0));
    expect(parsed.category, equals('Dining'));

    print('Testing Embedding Model: ${AIConfig.embeddingModel}');
    final vec = await service.generateEmbedding('dinner at kismat');
    print('Embedding result length: ${vec?.length}');
    expect(vec?.length, equals(768));

    // Test Local Vector Search & Note Enrichment
    final store = LocalVectorStore();
    for (final tx in MockData.initialTransactions) {
      final noteSuffix = (tx.note != null && tx.note!.trim().isNotEmpty) ? ' - ${tx.note!.trim()}' : '';
      final text = '${tx.isIncome ? "Income" : "Spent"} ₹${tx.amount.toStringAsFixed(0)} on ${tx.title}$noteSuffix (${tx.category}) via ${tx.paymentMode}';
      final docVec = LocalVectorStore.deterministicEmbed(text);
      await store.upsert(VectorDocument(
        id: tx.id,
        text: text,
        vector: docVec,
        metadata: {
          'amount': tx.amount,
          'category': tx.category,
          'type': tx.type.name,
          'date': tx.date.toIso8601String(),
          'title': tx.title,
          'note': tx.note,
        },
      ));
    }

    final chromaQueryVec = LocalVectorStore.deterministicEmbed('Chroma adapter');
    final searchResults = store.search(chromaQueryVec, topK: 1);
    expect(searchResults.isNotEmpty, isTrue);
    expect(searchResults.first.toCompactString(), contains('Chroma'));
    expect(searchResults.first.toCompactString(), contains('USB-C'));

    // Test RAG Query with full context
    final ragResponse = await service.queryRAG(
      query: 'What did I buy at Chroma?',
      currentBudget: 50000,
      totalSpent: 32450,
      currentMonth: 'April 2026',
      categoryBreakdown: [
        {'name': 'Food', 'allocated': 10000.0, 'spent': 8000.0},
        {'name': 'Electronics', 'allocated': 5000.0, 'spent': 1290.0},
      ],
    );
    print('RAG Response answer: ${ragResponse["answer"]}');
    print('RAG Response insight: ${ragResponse["insight"]}');
    expect(ragResponse['answer'], isNotEmpty);
  }, timeout: const Timeout(Duration(minutes: 1)));
}

