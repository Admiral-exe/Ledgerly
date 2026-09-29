import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/user_model.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = ApiConstants.baseUrl});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Health check to check if Render service is awake
  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl${ApiConstants.healthEndpoint}'))
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Get User Profile
  Future<UserModel?> getUser() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl${ApiConstants.userEndpoint}'), headers: _headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return UserModel.fromMap(data['data']);
        }
      }
    } catch (e) {
      // Fallback handled by caller
    }
    return null;
  }

  // Get Transactions
  Future<List<TransactionModel>?> getTransactions() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl${ApiConstants.transactionsEndpoint}'), headers: _headers)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List)
              .map((item) => TransactionModel.fromMap(item))
              .toList();
        }
      }
    } catch (_) {}
    return null;
  }

  // Post Transaction
  Future<TransactionModel?> createTransaction(TransactionModel tx) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${ApiConstants.transactionsEndpoint}'),
            headers: _headers,
            body: jsonEncode(tx.toMap()),
          )
          .timeout(const Duration(seconds: 6));
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return TransactionModel.fromMap(data['data']);
        }
      }
    } catch (_) {}
    return null;
  }

  // AI Chat Request
  Future<Map<String, String>?> sendAIChatQuery(String query) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl${ApiConstants.aiChatEndpoint}'),
            headers: _headers,
            body: jsonEncode({'query': query}),
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return {
            'answer': data['data']['answer']?.toString() ?? '',
            'insight': data['data']['insight']?.toString() ?? '',
          };
        }
      }
    } catch (_) {}
    return null;
  }
}
