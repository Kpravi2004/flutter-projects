class WaiterModel {
  final int id;
  String name;
  bool isActive;

  WaiterModel({
    required this.id,
    required this.name,
    this.isActive = true,
  });

  factory WaiterModel.fromJson(Map<String, dynamic> json) {
    return WaiterModel(
      id: json['waiterId'] as int? ?? 0,
      name: json['waiterName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'waiterName': name,
    };
  }
}