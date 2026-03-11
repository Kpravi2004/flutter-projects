class OrderItem {
  final String? id;               // String now
  final String productCode;
  final String productName;
  int quantity;
  double unitPrice;
  double? subtotal;

  OrderItem({
    this.id,
    required this.productCode,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.subtotal,
  }) {
    subtotal ??= quantity * unitPrice;
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      productCode: json['productCode'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'productCode': productCode,
    'productName': productName,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'subtotal': subtotal,
  };
}