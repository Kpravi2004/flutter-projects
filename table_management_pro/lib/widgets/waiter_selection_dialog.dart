import 'package:flutter/material.dart';
import '../models/waiter_model.dart';
import '../models/table_model.dart';
import '../utils/constants.dart';

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
              'Select Waiter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('For Table ${table.number}'),
            SizedBox(height: 16),

            waiters.isEmpty
                ? Padding(
              padding: EdgeInsets.all(20),
              child: Text('No waiters available'),
            )
                : Container(
              constraints: BoxConstraints(maxHeight: 250),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: waiters.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final waiter = waiters[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(waiter.name[0].toUpperCase()),
                    ),
                    title: Text(waiter.name),
                    subtitle: Text('Code: ${waiter.code}'),
                    onTap: () => onWaiterSelected(waiter),
                  );
                },
              ),
            ),

            SizedBox(height: 12),
            TextButton(
              onPressed: onAddWaiter,
              child: Text('+ Add New Waiter'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}