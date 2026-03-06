import 'package:flutter/material.dart';
import '../models/order_item.dart';
import '../utils/constants.dart'; // <-- changed to constants
import '../utils/helpers.dart';

class BillDialog extends StatelessWidget {
  final List<OrderItem> items;
  final DateTime orderDateTime;
  final VoidCallback onConfirm;

  const BillDialog({
    super.key,
    required this.items,
    required this.orderDateTime,
    required this.onConfirm,
  });

  double get _subtotal => items.fold(0, (sum, item) => sum + (item.subtotal ?? 0));
  double get _tax => _subtotal * 0.05;
  double get _total => _subtotal + _tax;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 460,
        decoration: BoxDecoration(
          color: AppConstants.lightSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with restaurant name
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.tealPrimary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const Text(
                    'SENTINIX RESTAURANT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bill Generated: ${Helpers.formatDate(orderDateTime)} ${Helpers.formatTime(orderDateTime)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Bill details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table headers
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppConstants.tealPrimary.withOpacity(0.5), width: 1),
                        top: BorderSide(color: AppConstants.tealPrimary.withOpacity(0.5), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text('Item', style: TextStyle(color: AppConstants.tealPrimary, fontWeight: FontWeight.bold))),
                        Expanded(flex: 1, child: Text('Qty', style: TextStyle(color: AppConstants.tealPrimary, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        Expanded(flex: 2, child: Text('Price', style: TextStyle(color: AppConstants.tealPrimary, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                        Expanded(flex: 2, child: Text('Total', style: TextStyle(color: AppConstants.tealPrimary, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Item rows
                  ...items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(color: AppConstants.textPrimary, fontSize: 14),
                              ),
                              Text(
                                'Code: ${item.productCode}',
                                style: TextStyle(color: AppConstants.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(color: AppConstants.textPrimary, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '₹ ${item.unitPrice.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppConstants.textPrimary, fontSize: 14),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '₹ ${item.subtotal!.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppConstants.tealPrimary, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: 16),

                  // Subtotal, tax, total
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.lightElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('Subtotal:', _subtotal),
                        const SizedBox(height: 6),
                        _buildSummaryRow('Tax (5%):', _tax),
                        const Divider(color: AppConstants.tealPrimary),
                        _buildSummaryRow('TOTAL:', _total, isTotal: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppConstants.textSecondary,
                            side: BorderSide(color: AppConstants.textSecondary.withOpacity(0.5)),
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
                            backgroundColor: AppConstants.tealPrimary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: onConfirm,
                          child: const Text('Confirm Bill', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? AppConstants.textPrimary : AppConstants.textSecondary,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
        Text(
          '₹ ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isTotal ? AppConstants.tealPrimary : AppConstants.textPrimary,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 20 : 16,
          ),
        ),
      ],
    );
  }
}