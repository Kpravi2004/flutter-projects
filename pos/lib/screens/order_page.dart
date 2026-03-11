import 'package:flutter/material.dart';
import '../services/order_api_service.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../utils/constants.dart';

class OrderPageNew extends StatefulWidget {
  const OrderPageNew({Key? key}) : super(key: key);

  @override
  State<OrderPageNew> createState() => _OrderPageNewState();
}

class _OrderPageNewState extends State<OrderPageNew> {
  List<Category> _categories = [];
  List<Product> _products = [];
  String? _selectedCategoryId;
  String _searchQuery = '';
  bool _isLoadingCategories = false;
  bool _isLoadingProducts = false;
  final Map<String, int> _cart = {};

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final data = await OrderApiService.fetchCategories();
      setState(() {
        _categories = data.map((json) => Category.fromJson(json)).toList();
        if (_categories.isNotEmpty && _selectedCategoryId == null) {
          _selectedCategoryId = _categories.first.id;
          _fetchProducts();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: $e')),
      );
    } finally {
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _fetchProducts() async {
    if (_selectedCategoryId == null) return;
    setState(() => _isLoadingProducts = true);
    try {
      final data = await OrderApiService.fetchProductsByCategory(
        categoryId: _selectedCategoryId!,
        search: _searchQuery,
        searchCode: _searchQuery,
      );
      final List<dynamic> rows = data['rows'] ?? [];
      setState(() {
        _products = rows.map((json) => Product.fromJson(json)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    } finally {
      setState(() => _isLoadingProducts = false);
    }
  }

  void _addToCart(Product product) {
    setState(() {
      _cart[product.id] = (_cart[product.id] ?? 0) + 1;
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
      if (_cart.containsKey(product.id)) {
        if (_cart[product.id]! > 1) {
          _cart[product.id] = _cart[product.id]! - 1;
        } else {
          _cart.remove(product.id);
        }
      }
    });
  }

  int get cartItemCount => _cart.values.fold(0, (sum, qty) => sum + qty);
  double get cartTotal {
    double total = 0;
    _cart.forEach((pid, qty) {
      final product = _products.firstWhere((p) => p.id == pid);
      total += product.basePrice * qty;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.lightBackground,
      appBar: AppBar(
        title: const Text('Order Products'),
        backgroundColor: AppConstants.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (cartItemCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.white),
                  const SizedBox(width: 4),
                  Text('$cartItemCount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left sidebar: Categories (narrow width)
          Container(
            width: 100,
            color: AppConstants.lightSurface,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategoryId == cat.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = cat.id;
                      _products = [];
                    });
                    _fetchProducts();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppConstants.primaryLight : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                      border: isSelected ? Border.all(color: AppConstants.primaryColor, width: 1.5) : null,
                    ),
                    child: Column(
                      children: [
                        if (cat.image != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              cat.image!,
                              height: 35,
                              width: 35,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.category, color: AppConstants.primaryColor),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          cat.name,
                          style: TextStyle(
                            color: isSelected ? AppConstants.primaryColor : AppConstants.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Main content (product area)
          Expanded(
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      _fetchProducts();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by name or code...',
                      prefixIcon: Icon(Icons.search, color: AppConstants.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppConstants.lightSurface,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                // Product grid
                Expanded(
                  child: _isLoadingProducts
                      ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
                      : _products.isEmpty
                      ? Center(child: Text('No products', style: TextStyle(color: AppConstants.textSecondary)))
                      : GridView.builder(
                    padding: const EdgeInsets.all(6),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75, // slightly taller cards
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final qty = _cart[product.id] ?? 0;
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image – fixed height
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              child: Container(
                                height: 100,
                                width: double.infinity,
                                color: AppConstants.primaryLight,
                                child: product.image != null
                                    ? Image.network(
                                  product.image!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(Icons.fastfood, color: AppConstants.primaryColor),
                                )
                                    : Icon(Icons.fastfood, color: AppConstants.primaryColor),
                              ),
                            ),
                            // Details – compact padding and spacing
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0), // reduced bottom padding
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₹${product.basePrice.toStringAsFixed(2)}',
                                    style: const TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                  const SizedBox(height: 1), // minimal space before buttons
                                  // Quantity controls – always visible
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.remove_circle_outline,
                                          color: qty > 0 ? Colors.red : Colors.grey,
                                          size: 18,
                                        ),
                                        onPressed: qty > 0 ? () => _removeFromCart(product) : null,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      Text(
                                        '$qty',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 18),
                                        onPressed: () => _addToCart(product),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Bottom cart bar
                if (cartItemCount > 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.lightSurface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -3)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Items: $cartItemCount', style: TextStyle(color: AppConstants.textSecondary, fontSize: 12)),
                              Text(
                                '₹${cartTotal.toStringAsFixed(2)}',
                                style: const TextStyle(color: AppConstants.primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Create order/bill
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('CREATE ORDER'),
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