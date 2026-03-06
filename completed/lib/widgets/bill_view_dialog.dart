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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppConstants.lightSurface,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bill #${bill['id']}',
              style: TextStyle(
                color: AppConstants.tealPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${Helpers.formatDate(dateTime)} ${Helpers.formatTime(dateTime)}',
              style: TextStyle(color: AppConstants.textSecondary),
            ),
            const Divider(height: 24),
            // Items list
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      item['productName'],
                      style: const TextStyle(color: AppConstants.textPrimary),
                    ),
                  ),
                  Text(
                    'x${item['quantity']}',
                    style: TextStyle(color: AppConstants.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '₹${(item['unitPrice'] * item['quantity']).toStringAsFixed(2)}',
                    style: const TextStyle(color: AppConstants.tealPrimary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${bill['totalAmount'].toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppConstants.tealPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.tealPrimary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 40),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}