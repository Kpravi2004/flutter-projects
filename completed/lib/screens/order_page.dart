import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/order_item.dart';
import '../providers/product_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/bill_dialog.dart';
import '../services/api_service.dart';

class OrderPage extends StatefulWidget {
  final List<int>? seatIds;
  final VoidCallback? onBillConfirmed;

  const OrderPage({super.key, this.seatIds, this.onBillConfirmed});

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

    final total = items.fold(0.0, (sum, item) => sum + (item.subtotal ?? 0));

    showDialog(
      context: context,
      builder: (ctx) => BillDialog(
        items: items,
        orderDateTime: DateTime.now(),
        onConfirm: () async {
          // 1. Create bill in backend with status 'pending'
          try {
            await ApiService.createBill(
              seatIds: widget.seatIds ?? [],
              items: items.map((item) => {
                'productCode': item.productCode,
                'productName': item.productName,
                'quantity': item.quantity,
                'unitPrice': item.unitPrice,
                'subtotal': item.subtotal,
              }).toList(),
              total: total,
              status: 'pending', // <-- added status
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to create bill: $e'),
                backgroundColor: AppConstants.errorRed,
              ),
            );
            return; // stop further actions
          }

          // 2. Mark seats as billed if seatIds are provided
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

          // 3. Call the callback to refresh tables
          widget.onBillConfirmed?.call();

          // 4. Close dialog and clear cart
          Navigator.pop(ctx);
          setState(() => _cart.clear());

          // 5. Show success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bill created!'),
              backgroundColor: AppConstants.successGreen,
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
      appBar: AppBar(
        title: const Text('Order Products'),
        backgroundColor: AppConstants.tealPrimary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                      border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.4), width: 1.5),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(color: AppConstants.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search by name/code',
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
                    border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.4), width: 1.5),
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
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppConstants.tealLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    product.category,
                                    style: const TextStyle(
                                      color: AppConstants.tealPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline,
                                  color: qty > 0 ? AppConstants.errorRed : Colors.grey, size: 22),
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
                                    color: AppConstants.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline, color: AppConstants.successGreen, size: 22),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _cart.isEmpty ? null : _showBill,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.tealPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: const Text(
                'CREATE BILL',  // <-- changed from 'GENERATE BILL'
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}