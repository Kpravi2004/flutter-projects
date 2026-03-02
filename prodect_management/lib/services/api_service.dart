import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:cross_file/cross_file.dart'; // for XFile
import '../models/product.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import 'constants.dart';

class ApiService {
  static final String baseUrl = AppConstants.baseUrl;

  // Helper to guess content type from filename
  static String _getContentType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  // ─── PRODUCTS ──────────────────────────────────────────────

  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('Failed to load products');
  }

  static Future<Product> createProduct(Product product, {XFile? imageFile}) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/products/upload'));

    request.fields['code'] = product.code;
    request.fields['name'] = product.name;
    request.fields['price'] = product.price.toString();
    request.fields['category'] = product.category;

    if (imageFile != null) {
      // Read bytes from XFile (works on mobile and web)
      final bytes = await imageFile.readAsBytes();
      final filename = imageFile.name;
      final contentType = MediaType.parse(_getContentType(filename));

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
          contentType: contentType,
        ),
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create product: ${response.body}');
  }

  static Future<Product> updateProduct(int id, Product product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to update product');
  }

  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }

  // ─── ORDERS ─────────────────────────────────────────────────
  static Future<Order> createOrder(Order order) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order.toJson()),
    );
    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create order');
  }

  static Future<Order> addOrderItem(String orderCode, OrderItem item) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders/$orderCode/items'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item.toJson()),
    );
    if (response.statusCode == 200) {
      return Order.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to add item');
  }
}