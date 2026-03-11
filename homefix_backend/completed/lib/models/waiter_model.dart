class WaiterModel {
  final String id;
  String name;
  bool isActive;

  WaiterModel({
    required this.id,
    required this.name,
    this.isActive = true,
  });

  factory WaiterModel.fromJson(Map<String, dynamic> json) {
    return WaiterModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['waiterName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'waiterName': name,
  };
}