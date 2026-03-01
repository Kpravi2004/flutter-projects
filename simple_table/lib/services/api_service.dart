import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/table_model.dart';
import '../models/seat_model.dart';

class ApiService {
  // Base URL – adjust based on your environment
  // Android emulator: 10.0.2.2
  // iOS simulator: localhost
  // Real device: your computer's local IP
  static const String baseUrl = 'http://localhost:8080';

  // ==================== TABLES ====================

  /// Fetch all tables with their seats
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

  /// Create a new table (table only, seats will be added separately)
  static Future<TableModel> createTable(Map<String, dynamic> tableData) async {
    final url = Uri.parse('$baseUrl/tables');
    final payload = {
      'table_number': int.tryParse(tableData['table_number'].toString()) ?? 0,
      'table_name': tableData['table_name'].toString(),
      'total_seats': tableData['total_seats'] as int,
      'status': tableData['status'].toString(),
      'floor_name': tableData['floor_name'].toString(),
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
        throw Exception('Failed to create table: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException catch (_) {
      throw Exception('Request timeout');
    } catch (e) {
      print('Network error creating table: $e');
      rethrow;
    }
  }

  /// Update a table (basic fields only, does NOT update seats)
  static Future<void> updateTable(TableModel table) async {
    final url = Uri.parse('$baseUrl/tables/${table.id}');
    final payload = {
      'table_number': int.tryParse(table.number) ?? table.number,
      'table_name': table.name,
      'total_seats': table.maxGuests,
      'status': table.status == TableStatus.free ? 'Active' : 'Inactive',
      'floor_name': table.floor,
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

  /// Delete a table by ID
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

  /// Create a single seat for a specific table
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
      if (response.statusCode == 201) {
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

  /// Update a seat's status using the dedicated endpoint
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

  /// Get all seats for a table
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

  /// Delete a seat
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
}