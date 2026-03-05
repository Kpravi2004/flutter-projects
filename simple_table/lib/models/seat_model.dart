class SeatModel {
  final int id;
  final int seatNo;
  String status;
  final String colorCode;
  final int tableId;
  bool billingStatus;

  SeatModel({
    required this.id,
    required this.seatNo,
    required this.status,
    required this.colorCode,
    required this.tableId,
    this.billingStatus = false,
  });

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return SeatModel(
      id: parseId(json['seatId']),
      seatNo: parseId(json['seat_no']),
      status: json['status'] as String? ?? 'Free',
      colorCode: json['color_code'] as String? ?? 'White',
      tableId: parseId(json['tableId']),
      billingStatus: json['billing_status'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seatId': id,
      'seat_no': seatNo,
      'status': status,
      'color_code': colorCode,
      'tableId': tableId,
      'billing_status': billingStatus,
    };
  }
}