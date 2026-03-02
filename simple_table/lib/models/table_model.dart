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
  int? waiterId;           // integer ID from waiter
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

  factory TableModel.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    int id = parseId(json['tableId']);
    int maxGuests = parseId(json['total_seats']);
    String number = json['table_number']?.toString() ?? '';
    String name = json['table_name']?.toString() ?? '';
    String floor = json['floor_name']?.toString().trim() ?? 'Main Floor';
    String statusStr = json['status']?.toString() ?? 'free';

    List<SeatModel> seats = [];
    if (json['seats'] != null && json['seats'] is List) {
      seats = (json['seats'] as List)
          .map((s) {
        (s as Map<String, dynamic>)['tableId'] = id;
        return SeatModel.fromJson(s);
      })
          .toList();
    }
    int guests = seats.where((s) => s.status == 'Occupied').length;

    return TableModel(
      id: id,
      number: number,
      name: name,
      status: _parseStatus(statusStr),
      guests: guests,
      maxGuests: maxGuests,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      floor: floor,
      seats: seats,
      waiterId: json['waiterId'] as int?,
      waiterName: json['waiterName'] as String?,
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
      'tableId': id,
      'table_number': int.tryParse(number) ?? number,
      'table_name': name,
      'total_seats': maxGuests,
      'status': backendStatus,
      'floor_name': floor,
      'waiterId': waiterId,
      'waiterName': waiterName,
      'seats': seats.map((s) => s.toJson()).toList(),
    };
  }

  void updateSeatsFromGuestCount() {
    for (int i = 0; i < seats.length; i++) {
      seats[i].status = (i < guests) ? 'Occupied' : 'Free';
    }
  }
}