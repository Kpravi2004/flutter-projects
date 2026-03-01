import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final prods = await ApiService.fetchProducts();
      setState(() {
        _products = prods;
        _isLoading = false;
      });
    } catch (e) {
      _isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    }
  }

  void _openProductDialog({Product? product}) {
    final isEditing = product != null;
    final codeController = TextEditingController(text: product?.code ?? '');
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final categoryController = TextEditingController(text: product?.category ?? '');
    final imageController = TextEditingController(text: product?.imagePath ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEditing ? 'Edit Product' : 'Add Product',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Code', labelStyle: TextStyle(color: AppColors.goldAccent)),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: AppColors.goldAccent)),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price', labelStyle: TextStyle(color: AppColors.goldAccent)),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: AppColors.goldAccent)),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: 'Image URL', labelStyle: TextStyle(color: AppColors.goldAccent)),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldAccent,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        // Validate inputs
                        if (codeController.text.isEmpty ||
                            nameController.text.isEmpty ||
                            priceController.text.isEmpty) return;

                        final newProduct = Product(
                          code: codeController.text,
                          name: nameController.text,
                          price: double.parse(priceController.text),
                          category: categoryController.text,
                          imagePath: imageController.text.isNotEmpty ? imageController.text : null,
                        );

                        try {
                          if (isEditing) {
                            await ApiService.updateProduct(product!.code, newProduct);
                          } else {
                            await ApiService.createProduct(newProduct);
                          }
                          Navigator.pop(ctx);
                          _loadProducts();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                      child: Text(isEditing ? 'Update' : 'Add'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteProduct(String code) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Delete Product', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ApiService.deleteProduct(code);
        _loadProducts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        title: const Text('Manage Products', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _products.length,
        itemBuilder: (ctx, index) {
          final product = _products[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.darkElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.goldAccent.withOpacity(0.2)),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.goldAccent.withOpacity(0.2),
                backgroundImage: product.imagePath != null ? NetworkImage(product.imagePath!) : null,
                child: product.imagePath == null
                    ? const Icon(Icons.fastfood, color: AppColors.goldAccent)
                    : null,
              ),
              title: Text(product.name, style: const TextStyle(color: Colors.white)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Code: ${product.code}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text('₹${product.price.toStringAsFixed(2)} • ${product.category}',
                      style: const TextStyle(color: AppColors.goldAccent, fontSize: 12)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _openProductDialog(product: product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProduct(product.code),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openProductDialog(),
        backgroundColor: AppColors.goldAccent,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}