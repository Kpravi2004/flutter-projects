import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cross_file/cross_file.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/image_picker_button.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  static const List<String> _categoryOptions = ['Breakfast', 'Lunch', 'Dinner'];

  List<String> get _categories {
    final products = context.read<ProductProvider>().products;
    final set = <String>{'All'};
    for (var p in products) {
      if (p.category.isNotEmpty) set.add(p.category);
    }
    return set.toList()..sort();
  }

  List<Product> get _filteredProducts {
    final products = context.watch<ProductProvider>().products;
    return products.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.code.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.errorRed),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.successGreen),
    );
  }

  void _openProductDialog({Product? product}) {
    final isEditing = product != null;
    final codeController = TextEditingController(text: product?.code ?? '');
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    String selectedCategory = product?.category ?? _categoryOptions.first;
    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (ctx, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isEditing ? Icons.edit : Icons.add,
                          color: AppColors.primaryPink,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Edit Product' : 'Add Product',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Image preview – centered square box
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMedium,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryPink.withOpacity(0.3), width: 1.5),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: kIsWeb
                            ? Image.network(
                          selectedImage!.path,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.broken_image,
                            color: AppColors.textSecondary,
                            size: 40,
                          ),
                        )
                            : Image.file(
                          File(selectedImage!.path),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.broken_image,
                            color: AppColors.textSecondary,
                            size: 40,
                          ),
                        ),
                      )
                          : Icon(Icons.image, color: AppColors.textSecondary, size: 40),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Select image button
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setState(() => selectedImage = picked);
                        }
                      },
                      icon: Icon(Icons.camera_alt, color: AppColors.primaryPink, size: 18),
                      label: Text(
                        selectedImage == null ? 'Select Image' : 'Change Image',
                        style: TextStyle(color: AppColors.primaryPink),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Code field
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: 'Product Code',
                      labelStyle: TextStyle(color: AppColors.primaryPink),
                      prefixIcon: Icon(Icons.qr_code, color: AppColors.primaryPink, size: 20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primaryPink.withOpacity(0.4), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceLight,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  // Name field
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      labelStyle: TextStyle(color: AppColors.primaryPink),
                      prefixIcon: Icon(Icons.label, color: AppColors.primaryPink, size: 20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primaryPink.withOpacity(0.4), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceLight,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  // Category dropdown with label
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: TextStyle(
                          color: AppColors.primaryPink,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryPink.withOpacity(0.4), width: 1.5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            isExpanded: true,
                            dropdownColor: AppColors.surfaceLight,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                            icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryPink),
                            items: _categoryOptions.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => selectedCategory = value!);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Price field
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Price (₹)',
                      labelStyle: TextStyle(color: AppColors.primaryPink),
                      prefixIcon: Icon(Icons.currency_rupee, color: AppColors.primaryPink, size: 20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primaryPink.withOpacity(0.4), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceLight,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: BorderSide(color: AppColors.textSecondary.withOpacity(0.5), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPink,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () async {
                            if (codeController.text.isEmpty ||
                                nameController.text.isEmpty ||
                                priceController.text.isEmpty) {
                              _showError('Please fill all fields');
                              return;
                            }

                            final newProduct = Product(
                              id: product?.id ?? 0,
                              code: codeController.text,
                              name: nameController.text,
                              price: double.parse(priceController.text),
                              category: selectedCategory,
                            );

                            try {
                              if (isEditing) {
                                await context.read<ProductProvider>().updateProduct(
                                  product!.id,
                                  newProduct,
                                );
                              } else {
                                await context.read<ProductProvider>().addProduct(
                                  newProduct,
                                  imageFile: selectedImage,
                                );
                              }
                              Navigator.pop(ctx);
                              _showSuccess(isEditing ? 'Product updated' : 'Product added');
                            } catch (e) {
                              _showError('Error: $e');
                            }
                          },
                          child: Text(isEditing ? 'Update' : 'Add'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _deleteProduct(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        title: const Text('Delete Product', style: TextStyle(color: AppColors.textPrimary)),
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
        await context.read<ProductProvider>().deleteProduct(id);
        _showSuccess('Product deleted');
      } catch (e) {
        _showError('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProductProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search row with dropdown filter – thicker borders
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Row(
              children: [
                // Search bar
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryPink.withOpacity(0.4), width: 1.5),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search by name/code',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        prefixIcon: Icon(Icons.search, color: AppColors.primaryPink, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Category dropdown filter
                Container(
                  width: 120,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryPink.withOpacity(0.4), width: 1.5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      dropdownColor: AppColors.surfaceLight,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryPink),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value!);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Add button
                ElevatedButton(
                  onPressed: () => _openProductDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPink,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(50, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.add, size: 24),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Product list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Consumer<ProductProvider>(
              builder: (context, provider, _) {
                final filtered = _filteredProducts;
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No products found',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (ctx, index) {
                    final product = filtered[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryPink.withOpacity(0.2),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        leading: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryPink.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: product.imageUrl.isNotEmpty
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              product.imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.fastfood,
                                color: AppColors.primaryPink,
                                size: 30,
                              ),
                            ),
                          )
                              : Icon(
                            Icons.fastfood,
                            color: AppColors.primaryPink,
                            size: 30,
                          ),
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Code: ${product.code}',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryPink.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    product.category,
                                    style: const TextStyle(
                                      color: AppColors.primaryPink,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '₹${product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppColors.primaryPink,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: AppColors.primaryPink, size: 30), // increased size
                              onPressed: () => _openProductDialog(product: product),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 1), // gap between icons
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 30), // increased size
                              onPressed: () => _deleteProduct(product.id),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}