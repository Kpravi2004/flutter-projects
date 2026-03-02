enum TableStatus {
  free,
  occupied,
  reserved,
  cleaning,
  billed,
}

enum TableShape {
  rectangle, // Only rectangle tables
}

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
  String floor;
  List<BillSplit>? bills;

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
    required this.floor,
    this.bills,
  });
}