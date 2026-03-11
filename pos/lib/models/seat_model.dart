class SeatModel {
  final String seatId;
  final String seatName;
  final bool status; // true = active, false = inactive
  final String? tableId; // to link to a table

  SeatModel({
    required this.seatId,
    required this.seatName,
    required this.status,
    this.tableId,
  });

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    return SeatModel(
      seatId: json['id'] ?? '',
      seatName: json['name'] ?? '',
      status: json['status'] ?? false,
      // tableId can be a string or an object with _id
      tableId: json['tableId']?['_id'] ?? json['tableId'],
    );
  }
}