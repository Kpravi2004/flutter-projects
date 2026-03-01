import 'seat_model.dart';
import 'order_model.dart';

enum TableStatus {
  free,
  occupied,
  reserved,
  cleaning,
  billed,
}

enum TableShape {
  rectangle,
}

class TableModel {
  final int id;
  String number;           // table_number
  String name;             // table_name
  TableStatus status;
  int guests;              // derived from seats
  int maxGuests;           // total_seats
  double amount;
  String? waiterId;
  String? waiterName;
  String? cleaningTime;
  String? reservedTime;
  TableShape shape;
  String floor;            // floor_name
  List<BillSplit>? bills;
  List<SeatModel> seats;

  TableModel({
    required this.id,
    required this.number,
    required this.name,
    required this.status,
    required this.guests,
    required this.maxGuests,
    required this.amount,
    this.waiterId,
    this.waiterName,
    this.cleaningTime,
    this.reservedTime,
    this.shape = TableShape.rectangle,
    required this.floor,
    this.bills,
    required this.seats,
  });

  // =========================
  // ✅ JSON → Model
  // =========================
  factory TableModel.fromJson(Map<String, dynamic> json) {

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final int id = parseInt(json['tableId']);

    final String number =
        json['table_number']?.toString() ?? '';

    final String name =
        json['table_name']?.toString() ?? '';

    final int maxGuests =
    parseInt(json['total_seats']);

    final String floor =
        json['floor_name']?.toString().trim() ?? 'Main Floor';

    List<SeatModel> seats = [];

    if (json['seats'] != null && json['seats'] is List) {
      seats = (json['seats'] as List)
          .map((s) {
        final seatJson = s as Map<String, dynamic>;
        seatJson['tableId'] = id;   // inject parent id
        return SeatModel.fromJson(seatJson);
      })
          .toList();
    }

    final int guests =
        seats.where((s) => s.status == 'Occupied').length;

    return TableModel(
      id: id,
      number: number,
      name: name,
      status: _parseStatus(json['status']?.toString() ?? 'free'),
      guests: guests,
      maxGuests: maxGuests,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      floor: floor,
      seats: seats,
    );
  }

  // =========================
  // ✅ Model → JSON
  // =========================
  Map<String, dynamic> toJson() {

    String backendStatus;

    switch (status) {
      case TableStatus.free:
        backendStatus = 'Active';
        break;
      case TableStatus.occupied:
        backendStatus = 'Occupied';
        break;
      case TableStatus.reserved:
        backendStatus = 'Reserved';
        break;
      case TableStatus.cleaning:
        backendStatus = 'Inactive';
        break;
      case TableStatus.billed:
        backendStatus = 'Billed';
        break;
    }

    return {
      'tableId': id,
      'table_number': int.tryParse(number),
      'table_name': name,
      'total_seats': maxGuests,
      'status': backendStatus,
      'floor_name': floor,
      'seats': seats.map((s) => s.toJson()).toList(),
    };
  }

  // =========================
  // ✅ Status Mapping
  // =========================
  static TableStatus _parseStatus(String status) {

    switch (status.toLowerCase().trim()) {

      case 'active':
      case 'free':
        return TableStatus.free;

      case 'occupied':
        return TableStatus.occupied;

      case 'reserved':
        return TableStatus.reserved;

      case 'cleaning':
      case 'inactive':
        return TableStatus.cleaning;

      case 'billed':
        return TableStatus.billed;

      default:
        return TableStatus.free;
    }
  }

  // =========================
  // ✅ Seat Sync Logic
  // =========================
  void updateSeatsFromGuestCount() {
    for (int i = 0; i < seats.length; i++) {
      seats[i].status = (i < guests) ? 'Occupied' : 'Free';
    }
  }
}