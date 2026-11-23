/// Configuration and model toggles for Ledgerly's On-Device AI & RAG system.
class AIConfig {
  /// Gemini API Key with compile-time injection support.
  /// To pass via command line: flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyCeZxP40w5CFAl-0V3MRIRIfjyn60pq8uI',
  );

  /// Primary Generation Model
  /// (Uncomment any model to switch)
  static const String generationModel = 'gemini-2.5-flash';
  // static const String generationModel = 'gemini-flash-latest';
  // static const String generationModel = 'gemini-3.5-flash-lite';

  /// Primary Embedding Model
  /// (Uncomment any model to switch)
  static const String embeddingModel = 'gemini-embedding-001'; // 3072 dimensions
  // static const String embeddingModel = 'text-embedding-004'; // 768 dimensions
  // static const String embeddingModel = 'embedding-001';

  /// Strict Retrieval Budget: Top-K records returned to Gemini context
  static const int topK = 6;

  /// Cosine similarity threshold for relevance
  static const double similarityThreshold = 0.20;

  /// Flag to determine if an API key is configured
  static bool get hasApiKey =>
      geminiApiKey.isNotEmpty && geminiApiKey != 'your_gemini_api_key_here';
}
