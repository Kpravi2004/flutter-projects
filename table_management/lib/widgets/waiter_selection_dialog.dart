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
      elevation: 8,
      child: Container(
        width: 320,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 32,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Select Waiter',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'For Table ${table.number}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),

            // Waiter list
            waiters.isEmpty
                ? Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No waiters available',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
                : Container(
              constraints: BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: waiters.length,
                separatorBuilder: (context, index) => Divider(height: 1),
                itemBuilder: (context, index) {
                  final waiter = waiters[index];
                  if (!waiter.isActive) return SizedBox.shrink();
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppConstants.primaryColor,
                      child: Text(
                        waiter.name[0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      waiter.name,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('Code: ${waiter.code}'),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () => onWaiterSelected(waiter),
                  );
                },
              ),
            ),

            SizedBox(height: 16),

            // Add Waiter Button
            OutlinedButton.icon(
              onPressed: onAddWaiter,
              icon: Icon(Icons.add),
              label: Text('Add New Waiter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
                side: BorderSide(color: AppConstants.primaryColor),
              ),
            ),

            SizedBox(height: 8),

            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}