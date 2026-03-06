import 'package:flutter/material.dart';
import '../models/order_item.dart';
import '../utils/app_colors.dart';
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
  double get _tax => _subtotal * 0.05; // example 5% tax
  double get _total => _subtotal + _tax;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 460,
        decoration: BoxDecoration(
          color: AppConstants.lightSurface,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with restaurant name
            Container(
              padding: EdgeInsets.all(AppConstants.spacingLg),
              decoration: BoxDecoration(
                color: AppConstants.tealPrimary,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppConstants.radiusXl),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'SENTINIX RESTAURANT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppConstants.fontSizeXxl,
                      fontWeight: AppConstants.fontWeightBold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: AppConstants.spacingXs),
                  Text(
                    'Bill Generated: ${formatDate(orderDateTime)} ${formatTime(orderDateTime)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Bill details
            Padding(
              padding: EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table headers
                  Container(
                    padding: EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppConstants.tealPrimary.withOpacity(0.5),
                          width: 1,
                        ),
                        top: BorderSide(
                          color: AppConstants.tealPrimary.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Item',
                            style: TextStyle(
                              color: AppConstants.tealPrimary,
                              fontWeight: AppConstants.fontWeightBold,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Qty',
                            style: TextStyle(
                              color: AppConstants.tealPrimary,
                              fontWeight: AppConstants.fontWeightBold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Price',
                            style: TextStyle(
                              color: AppConstants.tealPrimary,
                              fontWeight: AppConstants.fontWeightBold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Total',
                            style: TextStyle(
                              color: AppConstants.tealPrimary,
                              fontWeight: AppConstants.fontWeightBold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppConstants.spacingSm),

                  // Item rows
                  ...items.map((item) => Padding(
                    padding: EdgeInsets.symmetric(vertical: AppConstants.spacingXs),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: TextStyle(
                                  color: AppConstants.textPrimary,
                                  fontSize: AppConstants.fontSizeSm,
                                ),
                              ),
                              Text(
                                'Code: ${item.productCode}',
                                style: TextStyle(
                                  color: AppConstants.textSecondary,
                                  fontSize: AppConstants.fontSizeXs,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '${item.quantity}',
                            style: TextStyle(
                              color: AppConstants.textPrimary,
                              fontSize: AppConstants.fontSizeSm,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '₹ ${item.unitPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppConstants.textPrimary,
                              fontSize: AppConstants.fontSizeSm,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '₹ ${item.subtotal!.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppConstants.tealPrimary,
                              fontWeight: AppConstants.fontWeightSemiBold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  )),

                  SizedBox(height: AppConstants.spacingMd),

                  // Subtotal, tax, total
                  Container(
                    padding: EdgeInsets.all(AppConstants.spacingMd),
                    decoration: BoxDecoration(
                      color: AppConstants.lightElevated,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('Subtotal:', _subtotal),
                        SizedBox(height: AppConstants.spacingSm),
                        _buildSummaryRow('Tax (5%):', _tax),
                        Divider(color: AppConstants.tealPrimary),
                        _buildSummaryRow('TOTAL:', _total, isTotal: true),
                      ],
                    ),
                  ),

                  SizedBox(height: AppConstants.spacingLg),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppConstants.textSecondary,
                            side: BorderSide(
                              color: AppConstants.textSecondary.withOpacity(0.5),
                              width: AppConstants.borderNormal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                            ),
                            padding: EdgeInsets.symmetric(vertical: AppConstants.spacingMd),
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
                            padding: EdgeInsets.symmetric(vertical: AppConstants.spacingMd),
                          ),
                          onPressed: onConfirm,
                          child: const Text(
                            'Confirm Bill',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
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
            fontWeight: isTotal ? AppConstants.fontWeightBold : AppConstants.fontWeightNormal,
            fontSize: isTotal ? AppConstants.fontSizeLg : AppConstants.fontSizeSm,
          ),
        ),
        Text(
          '₹ ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isTotal ? AppConstants.tealPrimary : AppConstants.textPrimary,
            fontWeight: isTotal ? AppConstants.fontWeightBold : AppConstants.fontWeightMedium,
            fontSize: isTotal ? AppConstants.fontSizeXl : AppConstants.fontSizeMd,
          ),
        ),
      ],
    );
  }
}