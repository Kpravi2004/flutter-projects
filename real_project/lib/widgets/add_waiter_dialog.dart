import 'package:flutter/material.dart';
import '../models/waiter_model.dart';
import '../utils/helpers.dart';

class AddWaiterDialog extends StatefulWidget {
  final Function(WaiterModel) onWaiterAdded;

  const AddWaiterDialog({
    Key? key,
    required this.onWaiterAdded,
  }) : super(key: key);

  @override
  State<AddWaiterDialog> createState() => _AddWaiterDialogState();
}

class _AddWaiterDialogState extends State<AddWaiterDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add New Waiter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Waiter Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Waiter Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addWaiter,
                    child: const Text('Add Waiter'),
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
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final newWaiter = WaiterModel(
      id: Helpers.generateId(),
      name: nameController.text,
      code: codeController.text,
    );

    widget.onWaiterAdded(newWaiter);
    Navigator.pop(context);
  }
}