import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../utils/helpers.dart';

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
  int selectedSeats = 4;
  late String selectedFloor;

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
        width: 350,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add New Table',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: tableNumberController,
              decoration: const InputDecoration(
                labelText: 'Table Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedFloor,
              decoration: const InputDecoration(
                labelText: 'Floor',
                border: OutlineInputBorder(),
              ),
              items: widget.floors.map((floor) {
                return DropdownMenuItem(
                  value: floor,
                  child: Text(floor),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedFloor = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            const Text('Number of Seats:'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [2, 4, 6, 8].map((seats) {
                return ChoiceChip(
                  label: Text('$seats'),
                  selected: selectedSeats == seats,
                  onSelected: (selected) {
                    if (selected) setState(() => selectedSeats = seats);
                  },
                );
              }).toList(),
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
                    onPressed: _addTable,
                    child: const Text('Add Table'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addTable() {
    if (tableNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter table number')),
      );
      return;
    }

    final newTable = TableModel(
      id: Helpers.generateId(),
      number: tableNumberController.text,
      status: TableStatus.free,
      guests: 0,
      maxGuests: selectedSeats,
      amount: 0,
      floor: selectedFloor,
    );

    widget.onTableAdded(newTable);
    Navigator.pop(context);
  }
}