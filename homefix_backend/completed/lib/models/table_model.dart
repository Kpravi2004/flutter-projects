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
  final String id;
  String number;           // table_number
  String name;             // table_name
  TableStatus status;
  int guests;
  int maxGuests;
  double amount;
  String? waiterId;
  String? waiterName;
  String? cleaningTime;
  String? reservedTime;
  TableShape shape;
  String floor;
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

  factory TableModel.fromJson(Map<String, dynamic> json) {
    String parseId(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    String number = json['table_number']?.toString() ?? json['tableNumber']?.toString() ?? '';
    String name = json['table_name']?.toString() ?? json['tableName'] ?? '';
    String floor = json['floor_name']?.toString().trim() ?? json['floorName'] ?? 'Main Floor';
    String statusStr = json['status']?.toString() ?? 'free';

    List<SeatModel> seats = [];
    if (json['seats'] != null && json['seats'] is List) {
      seats = (json['seats'] as List)
          .map((s) => SeatModel.fromJson(s))
          .toList();
    }
    int guests = seats.where((s) => s.status == 'Occupied').length;

    return TableModel(
      id: parseId(json['_id'] ?? json['id'] ?? json['tableId']),
      number: number,
      name: name,
      status: _parseStatus(statusStr),
      guests: guests,
      maxGuests: json['total_seats'] ?? json['totalSeats'] ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      floor: floor,
      seats: seats,
      waiterId: parseId(json['waiterId']),
      waiterName: json['waiterName']?.toString(),
    );
  }

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
      'table_number': int.tryParse(number) ?? 0,      // snake_case, always a number
      'table_name': name,
      'total_seats': maxGuests,
      'status': backendStatus,
      'floor_name': floor,
      'waiterId': waiterId,                           // optional, string or null
      'waiterName': waiterName,                       // optional
    };
  }

  void updateSeatsFromGuestCount() {
    for (int i = 0; i < seats.length; i++) {
      seats[i].status = (i < guests) ? 'Occupied' : 'Free';
    }
  }
}