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
            SnackBar(
              content: const Text('Order placed!'),
              backgroundColor: AppConstants.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusSm)),
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
                                Icons.remove_circle_outline,
                                color: qty > 0 ? AppConstants.errorRed : Colors.grey,
                                size: 22,
                              ),
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
                                style: TextStyle(
                                  color: AppConstants.textPrimary,
                                  fontWeight: AppConstants.fontWeightBold,
                                  fontSize: AppConstants.fontSizeMd,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: AppConstants.successGreen,
                                size: 22,
                              ),
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
            padding: EdgeInsets.all(AppConstants.spacingSm),
            child: ElevatedButton(
              onPressed: _cart.isEmpty ? null : _showBill,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.tealPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                ),
                elevation: 4,
              ),
              child: Text(
                'GENERATE BILL',
                style: TextStyle(
                  fontWeight: AppConstants.fontWeightBold,
                  fontSize: AppConstants.fontSizeMd,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}