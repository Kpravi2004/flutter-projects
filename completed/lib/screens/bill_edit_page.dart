import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/bill_view_dialog.dart';

class BillEditPage extends StatefulWidget {
  final Map<String, dynamic> bill;

  const BillEditPage({Key? key, required this.bill}) : super(key: key);

  @override
  State<BillEditPage> createState() => _BillEditPageState();
}

class _BillEditPageState extends State<BillEditPage> {
  late Map<String, int> _cart;
  late Map<String, Product> _productMap;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBillItems();
  }

  Future<void> _loadBillItems() async {
    await context.read<ProductProvider>().loadProducts();
    final products = context.read<ProductProvider>().products;
    _productMap = {for (var p in products) p.code: p};

    final items = List<Map<String, dynamic>>.from(widget.bill['items']);
    _cart = {};
    for (var item in items) {
      String code = item['productCode'].toString();
      _cart[code] = item['quantity'];
    }
    setState(() => _isLoading = false);
  }

  void _increment(Product product) {
    setState(() {
      _cart[product.code] = (_cart[product.code] ?? 0) + 1;
    });
  }

  void _decrement(Product product) {
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

  void _deleteItem(String productCode) {
    setState(() {
      _cart.remove(productCode);
    });
  }

  double get _total {
    double total = 0;
    _cart.forEach((code, qty) {
      final product = _productMap[code];
      if (product != null) {
        total += product.price * qty;
      }
    });
    return total;
  }

  Future<void> _previewBill() async {
    Map<String, dynamic> tempBill = {
      'id': widget.bill['id'],
      'dateTime': DateTime.now().toIso8601String(),
      'status': 'pending',
      'totalAmount': _total,
      'items': _cart.entries.map((entry) {
        final product = _productMap[entry.key];
        return {
          'productCode': entry.key,
          'productName': product?.name ?? '',
          'quantity': entry.value,
          'unitPrice': product?.price ?? 0,
          'subtotal': (product?.price ?? 0) * entry.value,
        };
      }).toList(),
      'tableNumbers': widget.bill['tableNumbers'],
      'waiterNames': widget.bill['waiterNames'],
      'paymentMethod': widget.bill['paymentMethod'],
    };
    showDialog(
      context: context,
      builder: (ctx) => BillViewDialog(bill: tempBill),
    );
  }

  Future<void> _confirmUpdate() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Bill'),
        content: const Text('Are you sure you want to update this bill?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.successGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _saveBill();
    }
  }

  Future<void> _saveBill() async {
    List<Map<String, dynamic>> items = [];
    _cart.forEach((code, qty) {
      final product = _productMap[code];
      if (product != null) {
        items.add({
          'productCode': code,
          'productName': product.name,
          'quantity': qty,
          'unitPrice': product.price,
          'subtotal': product.price * qty,
        });
      }
    });

    try {
      await ApiService.updateBill(widget.bill['id'], items, _total);
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill updated'), backgroundColor: AppConstants.successGreen),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update bill: $e'), backgroundColor: AppConstants.errorRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.lightBackground,
      appBar: AppBar(
        title: Text('Edit Bill #${widget.bill['id']}'),
        backgroundColor: AppConstants.tealPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye),
            onPressed: _cart.isEmpty ? null : _previewBill,
            tooltip: 'Preview',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _cart.isEmpty ? null : _confirmUpdate,
            tooltip: 'Update',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (widget.bill['tableNumbers'] != null || widget.bill['waiterNames'] != null)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppConstants.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (widget.bill['tableNumbers'] != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Row(
                        children: [
                          Icon(Icons.table_restaurant, color: AppConstants.tealPrimary, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Table: ${widget.bill['tableNumbers']}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  if (widget.bill['waiterNames'] != null)
                    Row(
                      children: [
                        Icon(Icons.person, color: AppConstants.tealPrimary, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Waiter: ${widget.bill['waiterNames']}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          Expanded(
            child: _cart.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No items in this bill',
                    style: TextStyle(color: AppConstants.textSecondary, fontSize: 16),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _cart.length,
              itemBuilder: (context, index) {
                final code = _cart.keys.elementAt(index);
                final qty = _cart[code]!;
                final product = _productMap[code];
                if (product == null) return const SizedBox();
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppConstants.tealPrimary.withOpacity(0.2), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppConstants.tealLight.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              product.code,
                              style: TextStyle(
                                color: AppConstants.tealPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Code: ${product.code}',
                                style: TextStyle(
                                  color: AppConstants.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '₹${product.price.toStringAsFixed(2)} each',
                                style: TextStyle(
                                  color: AppConstants.tealPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline,
                                  color: AppConstants.errorRed, size: 24),
                              onPressed: () => _decrement(product),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Container(
                              width: 30,
                              alignment: Alignment.center,
                              child: Text(
                                '$qty',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline,
                                  color: AppConstants.successGreen, size: 24),
                              onPressed: () => _increment(product),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: Colors.red, size: 22),
                              onPressed: () => _deleteItem(code),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
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
                        'Total Amount',
                        style: TextStyle(
                          color: AppConstants.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '₹${_total.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppConstants.tealPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
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