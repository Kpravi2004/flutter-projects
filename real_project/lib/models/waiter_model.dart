class WaiterModel {
  final String id;
  String name;
  String code;
  bool isActive;

  WaiterModel({
    required this.id,
    required this.name,
    required this.code,
    this.isActive = true,
  });
}