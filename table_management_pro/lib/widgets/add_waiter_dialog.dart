import 'package:flutter/material.dart';
import '../models/waiter_model.dart';
import '../utils/constants.dart';
import '../utils/helper.dart';

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
        width: 300,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add New Waiter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Waiter Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 12),

            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: 'Waiter Code',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            SizedBox(height: 12),

            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
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
                    child: Text('Add'),
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
    if (nameController.text.isEmpty || codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name and Code required'), backgroundColor: Colors.red),
      );
      return;
    }

    final newWaiter = WaiterModel(
      id: Helpers.generateId(),
      name: nameController.text,
      code: codeController.text,
      phone: phoneController.text.isEmpty ? null : phoneController.text,
    );

    widget.onWaiterAdded(newWaiter);
    Navigator.pop(context);
  }
}