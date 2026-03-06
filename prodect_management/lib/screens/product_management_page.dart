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
      SnackBar(
        content: Text(msg),
        backgroundColor: AppConstants.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusSm)),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppConstants.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusSm)),
      ),
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
        backgroundColor: AppConstants.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusXl)),
        child: Container(
          width: 420,
          padding: EdgeInsets.all(AppConstants.spacingLg),
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
                        padding: EdgeInsets.all(AppConstants.spacingSm),
                        decoration: BoxDecoration(
                          color: AppConstants.tealLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isEditing ? Icons.edit : Icons.add,
                          color: AppConstants.tealPrimary,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: AppConstants.spacingMd),
                      Text(
                        isEditing ? 'Edit Product' : 'Add Product',
                        style: TextStyle(
                          color: AppConstants.textPrimary,
                          fontSize: AppConstants.fontSizeXl,
                          fontWeight: AppConstants.fontWeightSemiBold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppConstants.spacingLg),

                  // Image preview – centered square box
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppConstants.lightElevated,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        border: Border.all(
                          color: AppConstants.tealPrimary.withOpacity(0.3),
                          width: AppConstants.borderNormal,
                        ),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                        child: kIsWeb
                            ? Image.network(
                          selectedImage!.path,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.broken_image,
                            color: AppConstants.textSecondary,
                            size: 40,
                          ),
                        )
                            : Image.file(
                          File(selectedImage!.path),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.broken_image,
                            color: AppConstants.textSecondary,
                            size: 40,
                          ),
                        ),
                      )
                          : Icon(Icons.image, color: AppConstants.textSecondary, size: 40),
                    ),
                  ),
                  SizedBox(height: AppConstants.spacingSm),

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
                      icon: Icon(Icons.camera_alt, color: AppConstants.tealPrimary, size: 18),
                      label: Text(
                        selectedImage == null ? 'Select Image' : 'Change Image',
                        style: TextStyle(color: AppConstants.tealPrimary),
                      ),
                    ),
                  ),
                  SizedBox(height: AppConstants.spacingMd),

                  // Code field
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: 'Product Code',
                      labelStyle: TextStyle(color: AppConstants.tealPrimary),
                      prefixIcon: Icon(Icons.qr_code, color: AppConstants.tealPrimary, size: 20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: BorderSide(
                          color: AppConstants.tealPrimary.withOpacity(0.3),
                          width: AppConstants.borderNormal,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: BorderSide(color: AppConstants.tealPrimary, width: 2),
                      ),
                      filled: true,
                      fillColor: AppConstants.lightElevated,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: TextStyle(color: AppConstants.textPrimary),
                  ),
                  SizedBox(height: AppConstants.spacingMd),

                  // Name field
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      labelStyle: TextStyle(color: AppConstants.tealPrimary),
                      prefixIcon: Icon(Icons.label, color: AppConstants.tealPrimary, size: 20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: BorderSide(
                          color: AppConstants.tealPrimary.withOpacity(0.3),
                          width: AppConstants.borderNormal,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: BorderSide(color: AppConstants.tealPrimary, width: 2),
                      ),
                      filled: true,
                      fillColor: AppConstants.lightElevated,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: TextStyle(color: AppConstants.textPrimary),
                  ),
                  SizedBox(height: AppConstants.spacingMd),

                  // Category dropdown with label
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: TextStyle(
                          color: AppConstants.tealPrimary,
                          fontSize: AppConstants.fontSizeSm,
                          fontWeight: AppConstants.fontWeightMedium,
                        ),
                      ),
                      SizedBox(height: AppConstants.spacingXs),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppConstants.lightElevated,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          border: Border.all(
                            color: AppConstants.tealPrimary.withOpacity(0.3),
                            width: AppConstants.borderNormal,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            isExpanded: true,
                            dropdownColor: AppConstants.lightSurface,
                            style: TextStyle(
                              color: AppConstants.textPrimary,
                              fontSize: AppConstants.fontSizeMd,
                            ),
                            icon: Icon(Icons.arrow_drop_down, color: AppConstants.tealPrimary),
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
                  SizedBox(height: AppConstants.spacingMd),

                  // Price field
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Price (₹)',
                      labelStyle: TextStyle(color: AppConstants.tealPrimary),
                      prefixIcon: Icon(Icons.currency_rupee, color: AppConstants.tealPrimary, size: 20),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: BorderSide(
                          color: AppConstants.tealPrimary.withOpacity(0.3),
                          width: AppConstants.borderNormal,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        borderSide: BorderSide(color: AppConstants.tealPrimary, width: 2),
                      ),
                      filled: true,
                      fillColor: AppConstants.lightElevated,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: AppConstants.textPrimary),
                  ),
                  SizedBox(height: AppConstants.spacingLg),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppConstants.textSecondary,
                            side: BorderSide(
                              color: AppConstants.textSecondary.withOpacity(0.5),
                              width: AppConstants.borderNormal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      SizedBox(width: AppConstants.spacingMd),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.tealPrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                            ),
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
        backgroundColor: AppConstants.lightSurface,
        title: Text(
          'Delete Product',
          style: TextStyle(color: AppConstants.textPrimary),
        ),
        content: Text(
          'Are you sure?',
          style: TextStyle(color: AppConstants.textSecondary),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMd)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppConstants.errorRed),
            ),
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
      backgroundColor: AppConstants.lightBackground,
      body: Column(
        children: [
          // Search row with dropdown filter
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppConstants.spacingSm,
              AppConstants.spacingXs,
              AppConstants.spacingSm,
              AppConstants.spacingSm,
            ),
            child: Row(
              children: [
                // Search bar
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppConstants.lightSurface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      border: Border.all(
                        color: AppConstants.tealPrimary.withOpacity(0.3),
                        width: AppConstants.borderNormal,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: TextStyle(
                        color: AppConstants.textPrimary,
                        fontSize: AppConstants.fontSizeSm,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by name/code',
                        hintStyle: TextStyle(color: AppConstants.textHint),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppConstants.tealPrimary,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppConstants.spacingSm),
                // Category dropdown filter
                Container(
                  width: 120,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppConstants.lightSurface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    border: Border.all(
                      color: AppConstants.tealPrimary.withOpacity(0.3),
                      width: AppConstants.borderNormal,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      dropdownColor: AppConstants.lightSurface,
                      style: TextStyle(
                        color: AppConstants.textPrimary,
                        fontSize: AppConstants.fontSizeSm,
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: AppConstants.tealPrimary,
                      ),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(
                            cat,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value!);
                      },
                    ),
                  ),
                ),
                SizedBox(width: AppConstants.spacingSm),
                // Add button
                ElevatedButton(
                  onPressed: () => _openProductDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.tealPrimary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(50, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                  ),
                  child: const Icon(Icons.add, size: 24),
                ),
              ],
            ),
          ),

          SizedBox(height: AppConstants.spacingXs),

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
                      style: TextStyle(color: AppConstants.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (ctx, index) {
                    final product = filtered[index];
                    return Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingSm,
                        vertical: AppConstants.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.lightSurface,
                        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                        border: Border.all(
                          color: AppConstants.tealPrimary.withOpacity(0.2),
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
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingMd,
                          vertical: AppConstants.spacingSm,
                        ),
                        leading: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppConstants.tealLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                            border: Border.all(
                              color: AppConstants.tealPrimary.withOpacity(0.3),
                              width: AppConstants.borderThin,
                            ),
                          ),
                          child: product.imageUrl.isNotEmpty
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                            child: Image.network(
                              product.imageUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.fastfood,
                                color: AppConstants.tealPrimary,
                                size: 30,
                              ),
                            ),
                          )
                              : Icon(
                            Icons.fastfood,
                            color: AppConstants.tealPrimary,
                            size: 30,
                          ),
                        ),
                        title: Text(
                          product.name,
                          style: TextStyle(
                            color: AppConstants.textPrimary,
                            fontWeight: AppConstants.fontWeightBold,
                            fontSize: AppConstants.fontSizeMd,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: AppConstants.spacingXs),
                            Text(
                              'Code: ${product.code}',
                              style: TextStyle(
                                color: AppConstants.textSecondary,
                                fontSize: AppConstants.fontSizeXs,
                              ),
                            ),
                            SizedBox(height: AppConstants.spacingXs),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppConstants.spacingSm,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppConstants.tealLight,
                                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                                  ),
                                  child: Text(
                                    product.category,
                                    style: TextStyle(
                                      color: AppConstants.tealPrimary,
                                      fontSize: AppConstants.fontSizeXs,
                                      fontWeight: AppConstants.fontWeightSemiBold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: AppConstants.spacingSm),
                                Text(
                                  '₹${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: AppConstants.tealPrimary,
                                    fontWeight: AppConstants.fontWeightBold,
                                    fontSize: AppConstants.fontSizeMd,
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
                              icon: Icon(
                                Icons.edit,
                                color: AppConstants.tealPrimary,
                                size: 24,
                              ),
                              onPressed: () => _openProductDialog(product: product),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 24,
                              ),
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