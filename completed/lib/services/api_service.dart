import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:cross_file/cross_file.dart';
import '../models/table_model.dart';
import '../models/seat_model.dart';
import '../models/waiter_model.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../utils/constants.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080'; // e.g., 'http://localhost:8080'

  // ==================== TABLES ====================

  static Future<List<TableModel>> fetchTables() async {
    final url = Uri.parse('$baseUrl/tables');
    print('GET $url');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => TableModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tables: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      throw Exception('Request timeout');
    } catch (e) {
      print('Network error fetching tables: $e');
      rethrow;
    }
  }

  static Future<TableModel> createTable(Map<String, dynamic> tableData) async {
    final url = Uri.parse('$baseUrl/tables');
    final payload = {
      'table_number': tableData['table_number'] ?? 0,
      'table_name': tableData['table_name'] ?? '',
      'total_seats': tableData['total_seats'] ?? 0,
      'status': tableData['status'] ?? 'Active',
      'floor_name': tableData['floor_name'] ?? 'Main Floor',
    };
    print('POST $url with payload: $payload');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 10));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return TableModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create table: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      throw Exception('Request timeout');
    } catch (e) {
      print('Network error creating table: $e');
      rethrow;
    }
  }

  static Future<void> updateTable(TableModel table) async {
    final url = Uri.parse('$baseUrl/tables/${table.id}');
    final payload = table.toJson();
    print('PUT $url with payload: $payload');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 10));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('Failed to update table: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      throw Exception('Request timeout');
    } catch (e) {
      print('Network error updating table: $e');
      rethrow;
    }
  }

  static Future<void> deleteTable(int id) async {
    final url = Uri.parse('$baseUrl/tables/$id');
    print('DELETE $url');
    try {
      final response = await http.delete(url).timeout(const Duration(seconds: 10));
      print('Response status: ${response.statusCode}');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete table: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      throw Exception('Request timeout');
    } catch (e) {
      print('Network error deleting table: $e');
      rethrow;
    }
  }

  // ==================== SEATS ====================

  static Future<SeatModel> createSeat({
    required int tableId,
    required int seatNo,
    required String status,
    String colorCode = 'White',
  }) async {
    final url = Uri.parse('$baseUrl/seats/table/$tableId');
    final payload = {
      'seat_no': seatNo,
      'status': status,
      'color_code': colorCode,
    };
    print('POST $url with payload: $payload');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 10));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SeatModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create seat: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      throw Exception('Request timeout');
    } catch (e) {
      print('Network error creating seat: $e');
      rethrow;
    }
  }

  static Future<SeatModel> updateSeatStatus({
    required int seatId,
    required String status,
  }) async {
    final url = Uri.parse('$baseUrl/seats/$seatId/status?status=$status');
    print('PUT $url');
    try {
      final response = await http.put(url).timeout(const Duration(seconds: 10));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        return SeatModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update seat status: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      throw Exception('Request timeout');
    } catch (e) {
      print('Network error updating seat status: $e');
      rethrow;
    }
  }

  // Full seat update (seatNo, status, colorCode)
  static Future<SeatModel> updateSeat({
    required int seatId,
    required int seatNo,
    required String status,
    String colorCode = 'White',
  }) async {
    final url = Uri.parse('$baseUrl/seats/$seatId');
    final payload = {
      'seat_no': seatNo,
      'status': status,
      'color_code': colorCode,
    };
    print('PUT $url with payload: $payload');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 10));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        return SeatModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update seat: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      throw Exception('Request timeout');
    } catch (e) {
      print('Network error updating seat: $e');
      rethrow;
    }
  }

  static Future<List<SeatModel>> getSeatsByTable(int tableId) async {
    final url = Uri.parse('$baseUrl/seats/table/$tableId');
    print('GET $url');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SeatModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get seats: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      throw Exception('Request timeout');
    } catch (e) {
      print('Network error getting seats: $e');
      rethrow;
    }
  }

  static Future<void> deleteSeat(int seatId) async {
    final url = Uri.parse('$baseUrl/seats/$seatId');
    print('DELETE $url');
    try {
      final response = await http.delete(url).timeout(const Duration(seconds: 10));
      print('Response status: ${response.statusCode}');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete seat: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      throw Exception('Request timeout');
    } catch (e) {
      print('Network error deleting seat: $e');
      rethrow;
    }
  }

  // Dedicated method to update only billing status
  static Future<void> updateSeatBillingStatus(int seatId, bool billingStatus) async {
    final url = Uri.parse('$baseUrl/seats/$seatId/billing-status');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'billing_status': billingStatus}),
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Failed to update seat billing status: ${response.statusCode}');
    }
  }

  // ==================== WAITERS ====================

  static Future<List<WaiterModel>> fetchWaiters() async {
    final url = Uri.parse('$baseUrl/waiters');
    print('GET $url');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => WaiterModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load waiters: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      throw Exception('Request timeout');
    } catch (e) {
      print('Network error fetching waiters: $e');
      rethrow;
    }
  }

  static Future<WaiterModel> createWaiter(String name) async {
    final url = Uri.parse('$baseUrl/waiters');
    final payload = {
      'waiterName': name,
    };
    print('POST $url with payload: $payload');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 10));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return WaiterModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create waiter: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      throw Exception('Request timeout');
    } catch (e) {
      print('Network error creating waiter: $e');
      rethrow;
    }
  }

  // ==================== PRODUCTS ====================

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
      final bytes = await imageFile.readAsBytes();
      final filename = imageFile.name;
      final contentType = MediaType.parse('image/jpeg'); // you can improve detection
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

  // ==================== ORDERS ====================

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

  // ==================== BILLS ====================

  static Future<Map<String, dynamic>> createBill({
    required List<int> seatIds,
    required List<Map<String, dynamic>> items,
    required double total,
    String? status,
    String? paymentMethod,  // new
  }) async {
    final url = Uri.parse('$baseUrl/bills');
    final payload = {
      'seatIds': seatIds,
      'items': items,
      'total': total,
      if (status != null) 'status': status,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
    };
    print('POST $url with payload: $payload');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 10));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create bill: ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      throw Exception('Request timeout');
    } catch (e) {
      print('Network error creating bill: $e');
      rethrow;
    }
  }
  // ==================== BILLS (additional) ====================

  static Future<List<dynamic>> fetchAllBills() async {
    final response = await http.get(Uri.parse('$baseUrl/bills'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load bills');
  }

  static Future<List<dynamic>> fetchBillsByStatus(String status) async {
    final response = await http.get(Uri.parse('$baseUrl/bills/status/$status'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load bills');
  }

  static Future<void> confirmBill(int billId, {String? paymentMethod}) async {
    final url = Uri.parse('$baseUrl/bills/$billId/confirm');
    final Map<String, dynamic> body = {};
    if (paymentMethod != null) {
      body['paymentMethod'] = paymentMethod;
    }
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to confirm bill');
    }
  }
  static Future<void> updateBill(int billId, List<Map<String, dynamic>> items, double total) async {
    final url = Uri.parse('$baseUrl/bills/$billId');
    final payload = {
      'items': items,
      'total': total,
    };
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update bill');
    }
  }
  static Future<List<dynamic>> fetchBillsByDate(String date) async {
    final response = await http.get(Uri.parse('$baseUrl/bills/by-date?date=$date'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load bills');
  }
}