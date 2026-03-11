import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class OrderApiService {
  static const String baseUrl = ''; // Replace with your backend URL

  // Fetch categories
  // In lib/services/order_api_service.dart
  static Future<List<dynamic>> fetchCategories() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        print('❌ No authentication token found');
        throw Exception('Not authenticated');
      }

      final url = Uri.parse('http://localhost:5000/api/categories/name');
      print('🌐 GET $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        if (json['success'] == true) {
          final List<dynamic> data = json['data'] ?? [];
          print('✅ Categories fetched: ${data.length} items');
          return data; // ✅ return the list, not the whole map
        } else {
          throw Exception(json['message'] ?? 'Failed to load categories');
        }
      } else {
        print('❌ Failed with status ${response.statusCode}');
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('🔥 Exception caught: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
  // Fetch products for a category with search
  static Future<Map<String, dynamic>> fetchProductsByCategory({
    required String categoryId,
    String? search,
    String? searchCode,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final queryParams = {
        'categoryId': categoryId,
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (searchCode != null && searchCode.isNotEmpty) 'searchcode': searchCode,
      };
      final uri = Uri.parse('http://localhost:5000/api/products/pos/category-products').replace(queryParameters: queryParams);
      print('🌐 GET $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          return json;
        } else {
          throw Exception(json['message'] ?? 'Failed to load products');
        }
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('🔥 Exception in fetchProductsByCategory: $e');
      print(stackTrace);
      rethrow;
    }
  }
}