import 'order_item.dart';

class Order {
  final int? id;
  final String orderCode;
  int? tableId;
  int? waiterId;
  double total;
  String status;
  DateTime createdAt;
  List<OrderItem> items;

  Order({
    this.id,
    required this.orderCode,
    this.tableId,
    this.waiterId,
    required this.total,
    required this.status,
    required this.createdAt,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderCode: json['orderCode'],
      tableId: json['tableId'],
      waiterId: json['waiterId'],
      total: (json['total'] as num).toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      items: (json['items'] as List?)
              ?.map((i) => OrderItem.fromJson(i))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'orderCode': orderCode,
        'tableId': tableId,
        'waiterId': waiterId,
        'total': total,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };
}