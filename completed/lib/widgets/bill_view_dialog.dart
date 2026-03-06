import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class BillViewDialog extends StatelessWidget {
  final Map<String, dynamic> bill;

  const BillViewDialog({Key? key, required this.bill}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = List<Map<String, dynamic>>.from(bill['items']);
    final dateTime = DateTime.parse(bill['dateTime']);
    final subtotal = items.fold(0.0, (sum, item) => sum + (item['unitPrice'] * item['quantity']));
    final taxRate = 0.05; // 5% total tax (2.5% CGST + 2.5% SGST)
    final tax = subtotal * taxRate;
    final cgst = tax / 2;
    final sgst = tax / 2;
    final total = bill['totalAmount'];

    String tableNumbers = bill['tableNumbers'] ?? 'N/A';
    String waiterNames = bill['waiterNames'] ?? 'N/A';
    String paymentMethod = bill['paymentMethod'] ?? 'N/A';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Colors.white,
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Restaurant header
            Text(
              'ABC RESTAURANT',
              style: TextStyle(
                color: AppConstants.tealPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              '123 Main Street, Chennai',
              style: TextStyle(color: AppConstants.textSecondary, fontSize: 12),
            ),
            Text(
              'Phone: +91 9876543210',
              style: TextStyle(color: AppConstants.textSecondary, fontSize: 12),
            ),
            Text(
              'GSTIN: 33ABCDE1234F1Z5',
              style: TextStyle(color: AppConstants.textSecondary, fontSize: 12),
            ),
            const Divider(height: 24, thickness: 1, color: Colors.grey),

            // Bill details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bill No      : ${bill['id']}', style: const TextStyle(fontSize: 13)),
                      Text('Table No     : $tableNumbers', style: const TextStyle(fontSize: 13)),
                      Text('Date         : ${Helpers.formatDate(dateTime)}', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Time         : ${Helpers.formatTime(dateTime)}', style: const TextStyle(fontSize: 13)),
                      Text('Waiter       : $waiterNames', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1, color: Colors.grey),

            // Item headers
            Row(
              children: [
                Expanded(flex: 3, child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.tealPrimary))),
                Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.tealPrimary), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.tealPrimary), textAlign: TextAlign.right)),
                Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.tealPrimary), textAlign: TextAlign.right)),
              ],
            ),
            const Divider(thickness: 1, color: Colors.grey),

            // Items
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(item['productName'], style: const TextStyle(fontSize: 12))),
                  Expanded(flex: 1, child: Text('${item['quantity']}', style: const TextStyle(fontSize: 12), textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text('₹${item['unitPrice'].toStringAsFixed(2)}', style: const TextStyle(fontSize: 12), textAlign: TextAlign.right)),
                  Expanded(flex: 2, child: Text('₹${(item['unitPrice'] * item['quantity']).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
                ],
              ),
            )),
            const Divider(thickness: 1, color: Colors.grey),

            // Totals
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sub Total', style: TextStyle(fontSize: 13)),
                Text('₹${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('CGST 2.5%', style: TextStyle(fontSize: 13)),
                Text('₹${cgst.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('SGST 2.5%', style: TextStyle(fontSize: 13)),
                Text('₹${sgst.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13)),
              ],
            ),
            const Divider(thickness: 1, color: Colors.grey),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Grand Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('₹${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppConstants.tealPrimary)),
              ],
            ),
            const Divider(thickness: 1, color: Colors.grey),

            // Payment method
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payment:', style: TextStyle(fontSize: 13)),
                Text(paymentMethod, style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),

            // Footer
            Text(
              'Thank You! Visit Again',
              style: TextStyle(color: AppConstants.tealPrimary, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Close button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.tealPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 36),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}