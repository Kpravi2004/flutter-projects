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
  String floor; // New floor property

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
    required this.floor, // Make floor required
  }) : size = size ?? _calculateSize(maxGuests);

  static double _calculateSize(int maxGuests) {
    if (maxGuests <= 2) return 0.7;
    if (maxGuests <= 4) return 0.8;
    if (maxGuests <= 6) return 0.9;
    return 1.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'status': status.index,
      'guests': guests,
      'maxGuests': maxGuests,
      'amount': amount,
      'waiterId': waiterId,
      'waiterName': waiterName,
      'cleaningTime': cleaningTime,
      'reservedTime': reservedTime,
      'shape': shape.index,
      'size': size,
      'bills': bills?.map((b) => b.toJson()).toList(),
      'floor': floor,
    };
  }

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      number: json['number'],
      status: TableStatus.values[json['status']],
      guests: json['guests'],
      maxGuests: json['maxGuests'],
      amount: json['amount'].toDouble(),
      waiterId: json['waiterId'],
      waiterName: json['waiterName'],
      cleaningTime: json['cleaningTime'],
      reservedTime: json['reservedTime'],
      shape: TableShape.values[json['shape'] ?? 0],
      size: json['size']?.toDouble(),
      bills: json['bills'] != null
          ? (json['bills'] as List).map((b) => BillSplit.fromJson(b)).toList()
          : null,
      floor: json['floor'] ?? 'Ground Floor',
    );
  }

  TableModel copyWith({
    String? number,
    TableStatus? status,
    int? guests,
    int? maxGuests,
    double? amount,
    String? waiterId,
    String? waiterName,
    String? cleaningTime,
    String? reservedTime,
    TableShape? shape,
    List<BillSplit>? bills,
    String? floor,
  }) {
    return TableModel(
      id: this.id,
      number: number ?? this.number,
      status: status ?? this.status,
      guests: guests ?? this.guests,
      maxGuests: maxGuests ?? this.maxGuests,
      amount: amount ?? this.amount,
      waiterId: waiterId ?? this.waiterId,
      waiterName: waiterName ?? this.waiterName,
      cleaningTime: cleaningTime ?? this.cleaningTime,
      reservedTime: reservedTime ?? this.reservedTime,
      shape: shape ?? this.shape,
      bills: bills ?? this.bills,
      floor: floor ?? this.floor,
    );
  }
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'familyName': familyName,
      'guests': guests,
      'amount': amount,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  factory BillSplit.fromJson(Map<String, dynamic> json) {
    return BillSplit(
      id: json['id'],
      familyName: json['familyName'],
      guests: json['guests'],
      amount: json['amount'].toDouble(),
      items: (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList(),
    );
  }
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
    );
  }
}