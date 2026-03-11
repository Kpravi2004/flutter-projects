import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../utils/constants.dart';

class ProductSelectionDialog extends StatefulWidget {
  final Set<String> existingCodes;

  const ProductSelectionDialog({Key? key, required this.existingCodes}) : super(key: key);

  @override
  State<ProductSelectionDialog> createState() => _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends State<ProductSelectionDialog> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Product> get _filteredProducts {
    final products = context.watch<ProductProvider>().products;
    return products.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.code.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppConstants.lightSurface,
      child: Container(
        width: 400,
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Select Product',
              style: TextStyle(
                color: AppConstants.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search, color: AppConstants.tealPrimary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final filtered = _filteredProducts;
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text('No products found', style: TextStyle(color: AppConstants.textSecondary)),
                    );
                  }
                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (ctx, index) {
                      final product = filtered[index];
                      final bool isExisting = widget.existingCodes.contains(product.code);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isExisting ? AppConstants.successGreen.withOpacity(0.2) : AppConstants.tealLight,
                          child: Text(product.code),
                        ),
                        title: Text(product.name),
                        subtitle: Text('₹${product.price.toStringAsFixed(2)}'),
                        trailing: isExisting
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () => Navigator.pop(context, product),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}