import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/order_item.dart';
import '../providers/product_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class OrderPage extends StatefulWidget {
  final List<int>? seatIds;
  final VoidCallback? onBillConfirmed;

  const OrderPage({super.key, this.seatIds, this.onBillConfirmed});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final TextEditingController _nameSearchController = TextEditingController();
  final TextEditingController _codeSearchController = TextEditingController();
  String _nameQuery = '';
  String _codeQuery = '';
  String _selectedCategory = 'All';
  final Map<String, int> _cart = {};

  @override
  void dispose() {
    _nameSearchController.dispose();
    _codeSearchController.dispose();
    super.dispose();
  }

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
      final matchesName = _nameQuery.isEmpty ||
          p.name.toLowerCase().contains(_nameQuery.toLowerCase());
      final matchesCode = _codeQuery.isEmpty ||
          p.code.toLowerCase().contains(_codeQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      return matchesName && matchesCode && matchesCategory;
    }).toList();
  }

  double get _cartTotal {
    double total = 0;
    final products = context.read<ProductProvider>().products;
    _cart.forEach((code, qty) {
      final product = products.firstWhere((p) => p.code == code);
      total += product.price * qty;
    });
    return total;
  }

  int get _cartItemCount => _cart.values.fold(0, (sum, qty) => sum + qty);

  void _addToCart(Product product) {
    setState(() {
      _cart[product.code] = (_cart[product.code] ?? 0) + 1;
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

  Future<void> _createBill() async {
    if (_cart.isEmpty) return;

    final products = context.read<ProductProvider>().products;
    final items = _cart.entries.map((entry) {
      final product = products.firstWhere((p) => p.code == entry.key);
      return OrderItem(
        productCode: product.code,
        productName: product.name,
        quantity: entry.value,
        unitPrice: product.price,
      );
    }).toList();

    final total = items.fold(0.0, (sum, item) => sum + (item.subtotal ?? 0));

    try {
      await ApiService.createBill(
        seatIds: widget.seatIds ?? [],
        items: items.map((item) => ({
          'productCode': item.productCode,
          'productName': item.productName,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
          'subtotal': item.subtotal,
        })).toList(),
        total: total,
        status: 'pending',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create bill: $e'),
          backgroundColor: AppConstants.errorRed,
        ),
      );
      return;
    }

    if (widget.seatIds != null && widget.seatIds!.isNotEmpty) {
      try {
        for (int seatId in widget.seatIds!) {
          await ApiService.updateSeatBillingStatus(seatId, true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark seats: $e'),
            backgroundColor: AppConstants.errorRed,
          ),
        );
      }
    }

    widget.onBillConfirmed?.call();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProductProvider>().isLoading;
    final categories = _categories;

    return Scaffold(
      backgroundColor: AppConstants.lightBackground,
      appBar: AppBar(
        title: const Text('Order Products'),
        backgroundColor: AppConstants.tealPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_cartItemCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '$_cartItemCount',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left sidebar: Categories
          Container(
            width: 120,
            color: AppConstants.lightSurface,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppConstants.tealLight : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: AppConstants.tealPrimary, width: 1.5)
                          : null,
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? AppConstants.tealPrimary : AppConstants.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Search bars
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppConstants.lightSurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.3)),
                          ),
                          child: TextField(
                            controller: _nameSearchController,
                            onChanged: (v) => setState(() => _nameQuery = v),
                            decoration: InputDecoration(
                              hintText: 'Search by name...',
                              hintStyle: TextStyle(color: AppConstants.textHint),
                              prefixIcon: Icon(Icons.search, color: AppConstants.tealPrimary, size: 20),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppConstants.lightSurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.3)),
                          ),
                          child: TextField(
                            controller: _codeSearchController,
                            onChanged: (v) => setState(() => _codeQuery = v),
                            decoration: InputDecoration(
                              hintText: 'Search by code...',
                              hintStyle: TextStyle(color: AppConstants.textHint),
                              prefixIcon: Icon(Icons.qr_code, color: AppConstants.tealPrimary, size: 20),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Product grid
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? Center(
                    child: Text(
                      'No products found',
                      style: TextStyle(color: AppConstants.textSecondary),
                    ),
                  )
                      : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      final qty = _cart[product.code] ?? 0;
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product image
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Container(
                                height: 80,
                                width: double.infinity,
                                color: AppConstants.tealLight,
                                child: product.imageUrl.isNotEmpty
                                    ? Image.network(
                                  product.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.fastfood,
                                    color: AppConstants.tealPrimary,
                                  ),
                                )
                                    : const Icon(
                                  Icons.fastfood,
                                  color: AppConstants.tealPrimary,
                                ),
                              ),
                            ),
                            // Product details
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 0),
                                    Text(
                                      '₹${product.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: AppConstants.tealPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Spacer(),
                                    // Quantity controls
                                    if (qty == 0)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.add_circle_outline,
                                            color: AppConstants.tealPrimary,
                                            size: 24,
                                          ),
                                          onPressed: () => _addToCart(product),
                                        ),
                                      )
                                    else
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.remove_circle_outline,
                                              color: AppConstants.errorRed,
                                              size: 24,
                                            ),
                                            onPressed: () => _removeFromCart(product),
                                          ),
                                          Text(
                                            '$qty',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.add_circle_outline,
                                              color: AppConstants.successGreen,
                                              size: 24,
                                            ),
                                            onPressed: () => _addToCart(product),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Bottom cart bar
                if (_cartItemCount > 0)
                  Container(
                    padding: const EdgeInsets.all(1),
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
                                'Total Items: $_cartItemCount',
                                style: TextStyle(color: AppConstants.textSecondary),
                              ),
                              Text(
                                '₹${_cartTotal.toStringAsFixed(2)}',
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
                          onPressed: _createBill,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.tealPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('CREATE BILL'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}