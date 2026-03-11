import 'category.dart';
import 'product.dart';

class CategoryProducts {
  final String categoryId;
  final String categoryName;
  final List<Product> products;

  CategoryProducts({required this.categoryId, required this.categoryName, required this.products});

  factory CategoryProducts.fromJson(Map<String, dynamic> json) {
    return CategoryProducts(
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      products: (json['products'] as List? ?? []).map((p) => Product.fromJson(p)).toList(),
    );
  }
}