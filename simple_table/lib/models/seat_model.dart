class SeatModel {
  final int id;
  final int seatNo;
  String status;
  final String colorCode;
  final int tableId;

  SeatModel({
    required this.id,
    required this.seatNo,
    required this.status,
    required this.colorCode,
    required this.tableId,
  });

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    // Safe integer parsing
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return SeatModel(
      id: parseId(json['seatId']),
      seatNo: parseId(json['seatNo']),
      status: json['status'] as String? ?? 'Free',
      colorCode: json['colorCode'] as String? ?? 'White',
      tableId: parseId(json['tableId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seatId': id,
      'seatNo': seatNo,
      'status': status,
      'colorCode': colorCode,
      'tableId': tableId,
    };
  }
}