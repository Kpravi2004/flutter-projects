import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/table_model.dart';
import '../models/seat_model.dart';
import '../models/table_with_seats.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class ApiService {
  // Fetch all tables
  static Future<List<TableModel>> fetchTables() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final url = Uri.parse('${AppConstants.baseUrl}/tables');
    print('🌐 GET $url');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        final List<dynamic> data = json['data'] ?? [];
        return data.map((e) => TableModel.fromJson(e)).toList();
      } else {
        throw Exception(json['message'] ?? 'Failed to load tables');
      }
    } else {
      throw Exception('Failed to load tables: ${response.statusCode}');
    }
  }

  // Fetch all seats
  static Future<List<SeatModel>> fetchSeats() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Not authenticated');

    final url = Uri.parse('${AppConstants.baseUrl}/seat');
    print('🌐 GET $url');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        final List<dynamic> data = json['data'] ?? [];
        return data.map((e) => SeatModel.fromJson(e)).toList();
      } else {
        throw Exception(json['message'] ?? 'Failed to load seats');
      }
    } else {
      throw Exception('Failed to load seats: ${response.statusCode}');
    }
  }

  // Combine tables and seats into TableWithSeats list
  static Future<List<TableWithSeats>> fetchTablesWithAllSeats() async {
    final tables = await fetchTables();
    final seats = await fetchSeats();

    // Group seats by tableId
    final Map<String, List<SeatModel>> seatsByTable = {};
    for (var seat in seats) {
      if (seat.tableId != null) {
        seatsByTable.putIfAbsent(seat.tableId!, () => []).add(seat);
      }
    }

    // Build TableWithSeats list: for each table, attach its seats (empty list if none)
    return tables.map((table) {
      final tableSeats = seatsByTable[table.id] ?? [];
      return TableWithSeats(table: table, seats: tableSeats);
    }).toList();
  }
}