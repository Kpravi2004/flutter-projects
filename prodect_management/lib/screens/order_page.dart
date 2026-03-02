import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/order_item.dart';
import '../providers/product_provider.dart';
import '../utils/app_colors.dart';
import '../utils/helpers.dart';
import '../widgets/bill_dialog.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final Map<String, int> _cart = {};

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

  void _showBill() {
    if (_cart.isEmpty) return;

    final items = _cart.entries.map((entry) {
      final product = context.read<ProductProvider>().products.firstWhere((p) => p.code == entry.key);
      return OrderItem(
        productCode: product.code,
        productName: product.name,
        quantity: entry.value,
        unitPrice: product.price,
      );
    }).toList();

    showDialog(
      context: context,
      builder: (ctx) => BillDialog(
        items: items,
        orderDateTime: DateTime.now(),
        onConfirm: () {
          setState(() => _cart.clear());
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        },
      ),
    );
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
                      'No products available',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (ctx, index) {
                    final product = filtered[index];
                    final qty = _cart[product.code] ?? 0;
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
                              icon: Icon(Icons.remove_circle_outline,
                                  color: qty > 0 ? Colors.red : Colors.grey, size: 22),
                              onPressed: qty > 0
                                  ? () => setState(() {
                                if (qty == 1) {
                                  _cart.remove(product.code);
                                } else {
                                  _cart[product.code] = qty - 1;
                                }
                              })
                                  : null,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Container(
                              width: 28,
                              alignment: Alignment.center,
                              child: Text(
                                '$qty',
                                style: const TextStyle(
                                    color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline,
                                  color: Colors.green, size: 22),
                              onPressed: () => setState(() => _cart[product.code] = qty + 1),
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

          // Generate Bill button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _cart.isEmpty ? null : _showBill,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: const Text(
                'GENERATE BILL',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}