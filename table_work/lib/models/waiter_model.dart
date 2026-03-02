class WaiterModel {
  final String id;
  String name;
  String code;
  String? phone;
  bool isActive;
  String? imageUrl;
  double rating;
  int activeOrders;

  WaiterModel({
    required this.id,
    required this.name,
    required this.code,
    this.phone,
    this.isActive = true,
    this.imageUrl,
    this.rating = 4.5,
    this.activeOrders = 0,
  });
}