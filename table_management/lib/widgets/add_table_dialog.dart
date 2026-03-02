import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class AddTableDialog extends StatefulWidget {
  final Function(TableModel) onTableAdded;

  const AddTableDialog({
    Key? key,
    required this.onTableAdded,
  }) : super(key: key);

  @override
  _AddTableDialogState createState() => _AddTableDialogState();
}

class _AddTableDialogState extends State<AddTableDialog> {
  final TextEditingController tableNumberController = TextEditingController();
  int selectedSeats = 4;
  TableShape selectedShape = TableShape.square;
  TableStatus selectedStatus = TableStatus.free;
  String? cleaningTime;
  String? reservedTime;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 350,
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add New Table',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),

              // Table Number
              TextField(
                controller: tableNumberController,
                decoration: InputDecoration(
                  labelText: 'Table Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.table_restaurant),
                ),
              ),
              SizedBox(height: 16),

              // Status Selection
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Table Status:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: TableStatus.values.map((status) {
                  return ChoiceChip(
                    label: Text(status.toString().split('.').last),
                    selected: selectedStatus == status,
                    onSelected: (selected) {
                      setState(() {
                        selectedStatus = status;
                      });
                    },
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: _getStatusColor(status).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: selectedStatus == status
                          ? _getStatusColor(status)
                          : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),

              // Seat selection
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Number of Seats:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [2, 4, 6, 8].map((seats) {
                  return ChoiceChip(
                    label: Text('$seats'),
                    selected: selectedSeats == seats,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          selectedSeats = seats;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),

              // Shape selection
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Table Shape:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShapeOption(TableShape.square, Icons.crop_square, 'Square'),
                  _buildShapeOption(TableShape.rectangle, Icons.crop_landscape, 'Rectangle'),
                  _buildShapeOption(TableShape.round, Icons.circle, 'Round'),
                ],
              ),
              SizedBox(height: 16),

              // Additional fields based on status
              if (selectedStatus == TableStatus.cleaning)
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Cleaning Time (e.g., 20min)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => cleaningTime = value,
                ),

              if (selectedStatus == TableStatus.reserved)
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Reserved Time (e.g., 7:30PM)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => reservedTime = value,
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
                      onPressed: _addTable,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.successColor,
                      ),
                      child: Text('Add Table'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShapeOption(TableShape shape, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedShape = shape;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: selectedShape == shape
              ? AppConstants.primaryColor.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selectedShape == shape
                ? AppConstants.primaryColor
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selectedShape == shape
                  ? AppConstants.primaryColor
                  : Colors.grey,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selectedShape == shape
                    ? AppConstants.primaryColor
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.free:
        return AppConstants.freeColor;
      case TableStatus.occupied:
        return AppConstants.occupiedColor;
      case TableStatus.reserved:
        return AppConstants.reservedColor;
      case TableStatus.cleaning:
        return AppConstants.cleaningColor;
      case TableStatus.billed:
        return AppConstants.billedColor;
    }
  }

  void _addTable() {
    if (tableNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter table number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newTable = TableModel(
      id: Helpers.generateId(),
      number: tableNumberController.text,
      status: selectedStatus,
      guests: selectedStatus == TableStatus.occupied ? selectedSeats ~/ 2 : 0,
      maxGuests: selectedSeats,
      amount: 0,
      shape: selectedShape,
      cleaningTime: cleaningTime,
      reservedTime: reservedTime,
    );

    widget.onTableAdded(newTable);
  }
}