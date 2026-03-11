import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
class BillOrderPage extends StatefulWidget {
  final int billId;
  final List<Map<String, dynamic>> existingItems;

  const BillOrderPage({
    Key? key,
    required this.billId,
    required this.existingItems,
  }) : super(key: key);

  @override
  State<BillOrderPage> createState() => _BillOrderPageState();
}

class _BillOrderPageState extends State<BillOrderPage> {
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

  void _addToCart(Product product) {
    setState(() {
      if (_cart.containsKey(product.code)) {
        _cart[product.code] = _cart[product.code]! + 1;
      } else {
        _cart[product.code] = 1;
      }
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
      if (_cart.containsKey(product.code)) {
        if (_cart[product.code]! > 1) {
          _cart[product.code] = _cart[product.code]! - 1;
        } else {
          _cart.remove(product.code);
        }
      }
    });
  }

  double get _total {
    double total = 0;
    final products = context.read<ProductProvider>().products;
    _cart.forEach((code, qty) {
      final product = products.firstWhere((p) => p.code == code);
      total += product.price * qty;
    });
    return total;
  }

  Future<void> _addToBill() async {
    if (_cart.isEmpty) return;

    final Map<String, int> combinedItems = {};
    for (var item in widget.existingItems) {
      String code = item['productCode'].toString();
      combinedItems[code] = item['quantity'];
    }
    _cart.forEach((code, qty) {
      if (combinedItems.containsKey(code)) {
        combinedItems[code] = combinedItems[code]! + qty;
      } else {
        combinedItems[code] = qty;
      }
    });

    final products = context.read<ProductProvider>().products;
    List<Map<String, dynamic>> items = [];
    combinedItems.forEach((code, qty) {
      final product = products.firstWhere((p) => p.code == code);
      items.add({
        'productCode': code,
        'productName': product.name,
        'quantity': qty,
        'unitPrice': product.price,
        'subtotal': product.price * qty,
      });
    });

    double total = items.fold(0, (sum, item) => sum + item['subtotal']);

    try {
      await ApiService.updateBill(widget.billId, items, total);
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Products added to bill'), backgroundColor: AppConstants.successGreen),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add products: $e'), backgroundColor: AppConstants.errorRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProductProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppConstants.lightBackground,
      appBar: AppBar(
        title: Text('Add to Bill #${widget.billId}'),
        backgroundColor: AppConstants.tealPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.shopping_cart_checkout),
              onPressed: _addToBill,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppConstants.lightSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.4), width: 2.0), // thicker border
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(color: AppConstants.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: TextStyle(color: AppConstants.textHint),
                        prefixIcon: Icon(Icons.search, color: AppConstants.tealPrimary, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 120,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppConstants.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.4), width: 2.0), // thicker border
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      dropdownColor: AppConstants.lightSurface,
                      style: const TextStyle(color: AppConstants.textPrimary, fontSize: 13),
                      icon: Icon(Icons.arrow_drop_down, color: AppConstants.tealPrimary),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value!),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
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
                      style: TextStyle(color: AppConstants.textSecondary),
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
                        color: AppConstants.lightSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppConstants.tealPrimary.withOpacity(0.2),
                          width: 1.5, // slightly thicker border
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        leading: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppConstants.tealLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppConstants.tealPrimary.withOpacity(0.3),
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
                          style: const TextStyle(
                            color: AppConstants.textPrimary,
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
                                color: AppConstants.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppConstants.tealPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline,
                                  color: qty > 0 ? AppConstants.errorRed : Colors.grey, size: 22),
                              onPressed: qty > 0
                                  ? () => _removeFromCart(product)
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
                                    color: AppConstants.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline, color: AppConstants.successGreen, size: 22),
                              onPressed: () => _addToCart(product),
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
          if (_cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.lightSurface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total (additional)',
                          style: TextStyle(color: AppConstants.textSecondary, fontSize: 12),
                        ),
                        Text(
                          '₹${_total.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppConstants.tealPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _addToBill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.successGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Add to Bill'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}