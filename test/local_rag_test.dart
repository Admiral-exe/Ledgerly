import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerly/core/services/local_vector_store.dart';
import 'package:ledgerly/core/services/rag_ai_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('On-Device Local Vector Store & SIMD Search Tests', () {
    test('Deterministic vectorizer outputs consistent normalized vectors', () {
      final v1 = LocalVectorStore.deterministicEmbed('dinner at kismat kathyawadi');
      final v2 = LocalVectorStore.deterministicEmbed('dinner at kismat kathyawadi');
      final v3 = LocalVectorStore.deterministicEmbed('bought sensor from electronics shop');

      expect(v1.length, equals(768));
      expect(v2.length, equals(768));
      expect(v3.length, equals(768));

      // Identical strings produce identical vectors
      for (int i = 0; i < 768; i++) {
        expect(v1[i], closeTo(v2[i], 0.0001));
      }
    });

    test('In-memory SIMD search retrieves semantically closest record', () async {
      final store = LocalVectorStore();

      // Upsert mock records into memory store
      final doc1 = VectorDocument(
        id: 'doc_1',
        text: 'Spent ₹2000 on dinner at Kismat Kathiyawadi',
        vector: LocalVectorStore.deterministicEmbed('dinner kismat kathiyawadi food restaurant dining'),
        metadata: {
          'category': 'Dining',
          'amount': 2000,
          'date': '2026-04-02T19:30:00Z',
        },
      );

      final doc2 = VectorDocument(
        id: 'doc_2',
        text: 'Spent ₹4200 on fuel and highway tolls',
        vector: LocalVectorStore.deterministicEmbed('fuel highway tolls road trip travel petrol'),
        metadata: {
          'category': 'Travel',
          'amount': 4200,
          'date': '2026-04-03T10:00:00Z',
        },
      );

      final doc3 = VectorDocument(
        id: 'doc_3',
        text: 'Bought ₹500 arduino sensor module',
        vector: LocalVectorStore.deterministicEmbed('arduino sensor module electronics hardware'),
        metadata: {
          'category': 'sensor',
          'amount': 500,
          'date': '2026-04-04T12:00:00Z',
        },
      );

      await store.upsertBatch([doc1, doc2, doc3]);

      // Query for sensor
      final querySensor = LocalVectorStore.deterministicEmbed('arduino sensor');
      final sensorResults = store.search(querySensor, topK: 1);

      expect(sensorResults.isNotEmpty, isTrue);
      expect(sensorResults.first.document.id, equals('doc_3'));
      expect(sensorResults.first.document.metadata['category'], equals('sensor'));

      // Compact string validation
      final compact = sensorResults.first.toCompactString();
      expect(compact, contains('sensor'));
      expect(compact, contains('₹500'));
      expect(compact, contains('2026-04-04'));

      // Query for dinner
      final queryFood = LocalVectorStore.deterministicEmbed('dinner food');
      final foodResults = store.search(queryFood, topK: 1);
      expect(foodResults.isNotEmpty, isTrue);
      expect(foodResults.first.document.id, equals('doc_1'));
    });

    test('Local offline parser supports dynamic custom categories', () async {
      final service = RAGAIService();
      final res = await service.parseNaturalTransaction(
        'I bought 500rs of arduino sensor',
        categories: ['Dining', 'Travel', 'Shopping', 'Bills', 'sensor'],
      );

      expect(res.success, isTrue);
      expect(res.amount, equals(500.0));
      expect(res.category, equals('sensor'));
    });
  });
}
