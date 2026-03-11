class SeatModel {
  final String id;
  final int seatNo;
  String status;
  final String colorCode;
  final String tableId;
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
    String parseId(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    return SeatModel(
      id: parseId(json['_id'] ?? json['id'] ?? json['seatId']),
      seatNo: json['seat_no'] ?? json['seatNo'] ?? 0,
      status: json['status'] ?? 'Free',
      colorCode: json['color_code'] ?? json['colorCode'] ?? 'White',
      tableId: parseId(json['tableId'] ?? json['table']),
      billingStatus: json['billing_status'] ?? json['billingStatus'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'seatNo': seatNo,
    'status': status,
    'colorCode': colorCode,
    'billingStatus': billingStatus,
    // Usually the ID is not sent for updates unless necessary
  };
}