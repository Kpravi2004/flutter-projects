import 'package:flutter/material.dart';
import '../models/waiter_model.dart';
import '../models/table_model.dart';

class WaiterSelectionDialog extends StatelessWidget {
  final TableModel table;
  final List<WaiterModel> waiters;
  final Function(WaiterModel) onWaiterSelected;
  final VoidCallback onAddWaiter;

  const WaiterSelectionDialog({
    Key? key,
    required this.table,
    required this.waiters,
    required this.onWaiterSelected,
    required this.onAddWaiter,
  }) : super(key: key);

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
            Text(
              'Select Waiter for Table ${table.number}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            waiters.isEmpty
                ? const Text('No waiters available')
                : Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: waiters.length,
                itemBuilder: (context, index) {
                  final waiter = waiters[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(waiter.name[0]),
                    ),
                    title: Text(waiter.name),
                    subtitle: Text('Code: ${waiter.code}'),
                    onTap: () => onWaiterSelected(waiter),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: onAddWaiter,
              child: const Text('+ Add New Waiter'),
            ),
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