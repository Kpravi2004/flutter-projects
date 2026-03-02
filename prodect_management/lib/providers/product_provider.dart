import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'package:cross_file/cross_file.dart';
class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await ApiService.fetchProducts();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product, {XFile? imageFile}) async {
    try {
      final newProduct = await ApiService.createProduct(product, imageFile: imageFile);
      _products.add(newProduct);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(int id, Product product) async {
    try {
      final updated = await ApiService.updateProduct(id, product);
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await ApiService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}