import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../utils/constants.dart';

class AddTableDialog extends StatefulWidget {
  final List<String> floors;
  final String currentFloor;
  final Function(TableModel) onTableAdded;

  const AddTableDialog({
    Key? key,
    required this.floors,
    required this.currentFloor,
    required this.onTableAdded,
  }) : super(key: key);

  @override
  State<AddTableDialog> createState() => _AddTableDialogState();
}

class _AddTableDialogState extends State<AddTableDialog> {
  final TextEditingController tableNumberController = TextEditingController();
  final TextEditingController tableNameController = TextEditingController();
  int selectedSeats = 4;
  late String selectedFloor;
  String selectedStatus = 'Active';

  @override
  void initState() {
    super.initState();
    selectedFloor = widget.currentFloor;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Table icon at top
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.tealLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.table_restaurant,
                color: AppConstants.tealPrimary,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add New Table',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: tableNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Table Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: tableNameController,
              decoration: const InputDecoration(labelText: 'Table Name (optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedFloor,
              decoration: const InputDecoration(labelText: 'Floor', border: OutlineInputBorder()),
              items: widget.floors.map((floor) => DropdownMenuItem(value: floor, child: Text(floor))).toList(),
              onChanged: (value) => setState(() => selectedFloor = value!),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'Active', child: Text('Active')),
                DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
              ],
              onChanged: (value) => setState(() => selectedStatus = value!),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Text('Seats:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.remove_circle_outline, color: AppConstants.errorRed), // red for decrease
                  onPressed: selectedSeats > 1 ? () => setState(() => selectedSeats--) : null,
                ),
                Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                  child: Text('$selectedSeats', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: AppConstants.successGreen), // green for increase
                  onPressed: selectedSeats < 20 ? () => setState(() => selectedSeats++) : null,
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: _addTable, child: const Text('Add Table'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addTable() {
    if (tableNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter table number')));
      return;
    }

    if (int.tryParse(tableNumberController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Table number must be a number')));
      return;
    }

    TableStatus tableStatus = selectedStatus == 'Active' ? TableStatus.free : TableStatus.cleaning;

    final newTable = TableModel(
      id: 0,
      number: tableNumberController.text,
      name: tableNameController.text.isEmpty ? tableNumberController.text : tableNameController.text,
      status: tableStatus,
      guests: 0,
      maxGuests: selectedSeats,
      amount: 0,
      floor: selectedFloor.trim(),
      seats: [],
    );

    widget.onTableAdded(newTable);
    // Dialog will be closed by the caller after table creation
  }
}