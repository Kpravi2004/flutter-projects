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