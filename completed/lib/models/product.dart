import '../utils/constants.dart';

class Product {
  final int id;
  final String code;
  String name;
  double price;
  String category;

  Product({
    required this.id,
    required this.code,
    required this.name,
    required this.price,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'price': price,
    'category': category,
  };

  String get imageUrl => 'http://localhost:8080/products/$id/image';
}