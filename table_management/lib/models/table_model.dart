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
  }) : size = size ?? _calculateSize(maxGuests);

  static double _calculateSize(int maxGuests) {
    if (maxGuests <= 2) return 0.8;
    if (maxGuests <= 4) return 1.0;
    if (maxGuests <= 6) return 1.2;
    return 1.4;
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
    );
  }
}