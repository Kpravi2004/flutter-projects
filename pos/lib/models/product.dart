class Product {
  final String id;
  final String name;
  final double basePrice;
  final String? image;
  final bool hasAddons;
  final bool isStock;
  final int? availableQuantity;

  Product({
    required this.id,
    required this.name,
    required this.basePrice,
    this.image,
    this.hasAddons = false,
    this.isStock = false,
    this.availableQuantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      image: json['image'],
      hasAddons: json['hasAddons'] ?? false,
      isStock: json['isStock'] ?? false,
      availableQuantity: json['availableQuantity'],
    );
  }
}