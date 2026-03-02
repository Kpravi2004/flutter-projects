import 'package:flutter/material.dart';
import '../models/waiter_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class AddWaiterDialog extends StatefulWidget {
  final Function(WaiterModel) onWaiterAdded;

  const AddWaiterDialog({
    Key? key,
    required this.onWaiterAdded,
  }) : super(key: key);

  @override
  _AddWaiterDialogState createState() => _AddWaiterDialogState();
}

class _AddWaiterDialogState extends State<AddWaiterDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 350,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add New Waiter',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            // Name Field
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Waiter Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),

            // Code Field
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: 'Waiter Code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            SizedBox(height: 16),

            // Phone Field (Optional)
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addWaiter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.successColor,
                    ),
                    child: Text('Add Waiter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addWaiter() {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter waiter name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter waiter code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newWaiter = WaiterModel(
      id: Helpers.generateId(),
      name: nameController.text,
      code: codeController.text,
      phone: phoneController.text.isEmpty ? null : phoneController.text,
      isActive: true,
    );

    widget.onWaiterAdded(newWaiter);
  }
}