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

class OrderModel {
  final String id;
  final String tableId;
  final String waiterId;
  final DateTime orderTime;
  List<OrderItem> items;
  double total;
  OrderStatus status;

  OrderModel({
    required this.id,
    required this.tableId,
    required this.waiterId,
    required this.orderTime,
    required this.items,
    required this.total,
    this.status = OrderStatus.pending,
  });
}

enum OrderStatus {
  pending,
  preparing,
  ready,
  served,
  paid,
  cancelled,
}