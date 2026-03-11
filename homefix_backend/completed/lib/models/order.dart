import 'order_item.dart';

class Order {
  final String? id;               // String now
  final String orderCode;
  String? tableId;                 // String now
  String? waiterId;                // String now
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
      id: json['_id']?.toString() ?? json['id']?.toString(),
      orderCode: json['orderCode'] ?? '',
      tableId: json['tableId']?.toString(),
      waiterId: json['waiterId']?.toString(),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
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