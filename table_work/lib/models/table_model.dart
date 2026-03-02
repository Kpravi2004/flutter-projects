enum TableStatus {
  free,
  occupied,
  reserved,
  cleaning,
  billed,
}

enum TableShape {
  square,
  rectangle,
  round,
}

// Define BillSplit class before using it
class BillSplit {
  final String id;
  String familyName;
  int guests;
  double amount;
  List<OrderItem> items;

  BillSplit({
    required this.id,
    required this.familyName,
    required this.guests,
    required this.amount,
    required this.items,
  });
}

class OrderItem {
  final String id;
  String name;
  double price;
  int quantity;

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });
}

class TableModel {
  final String id;
  String number;
  TableStatus status;
  int guests;
  int maxGuests;
  double amount;
  String? waiterId;
  String? waiterName;
  String? cleaningTime;
  String? reservedTime;
  TableShape shape;
  double size;
  List<BillSplit>? bills;
  String? floor;
  List<String>? features;

  TableModel({
    required this.id,
    required this.number,
    required this.status,
    required this.guests,
    required this.maxGuests,
    required this.amount,
    this.waiterId,
    this.waiterName,
    this.cleaningTime,
    this.reservedTime,
    this.shape = TableShape.square,
    double? size,
    this.bills,
    this.floor,
    this.features,
  }) : size = size ?? _calculateSize(maxGuests);

  static double _calculateSize(int maxGuests) {
    if (maxGuests <= 2) return 0.7;
    if (maxGuests <= 4) return 0.8;
    if (maxGuests <= 6) return 0.9;
    return 1.0;
  }
}