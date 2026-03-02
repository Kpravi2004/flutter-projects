import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../utils/helper.dart';

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
  _AddTableDialogState createState() => _AddTableDialogState();
}

class _AddTableDialogState extends State<AddTableDialog> {
  final TextEditingController tableNumberController = TextEditingController();
  int selectedSeats = 4;
  TableShape selectedShape = TableShape.square;
  late String selectedFloor;

  // Elegant color palette
  final Color woodDark = Color(0xFF8B5A2B);
  final Color goldAccent = Color(0xFFD4AF37);
  final Color creamWhite = Color(0xFFF8F0E0);
  final Color velvetGreen = Color(0xFF2E5C4E);

  @override
  void initState() {
    super.initState();
    selectedFloor = widget.currentFloor;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Container(
        width: 360,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [creamWhite, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: woodDark.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Elegant Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [velvetGreen, woodDark],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: goldAccent.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(Icons.table_restaurant, color: Colors.white, size: 24),
                ),
                SizedBox(width: 12),
                Text(
                  'Add New Table',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: woodDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Table Number Field
            TextField(
              controller: tableNumberController,
              decoration: InputDecoration(
                labelText: 'Table Number',
                hintText: 'e.g., 101, Garden, VIP',
                labelStyle: TextStyle(color: woodDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: woodDark.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: woodDark.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: goldAccent, width: 2),
                ),
                prefixIcon: Icon(Icons.numbers, color: woodDark),
              ),
            ),
            SizedBox(height: 16),

            // Floor Selection
            DropdownButtonFormField<String>(
              value: selectedFloor,
              decoration: InputDecoration(
                labelText: 'Floor',
                labelStyle: TextStyle(color: woodDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: woodDark.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: goldAccent, width: 2),
                ),
                prefixIcon: Icon(Icons.location_on, color: woodDark),
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
            SizedBox(height: 20),

            // Seat Selection Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Number of Seats',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: woodDark,
                ),
              ),
            ),
            SizedBox(height: 12),

            // Seat Selection Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [2, 4, 6, 8].map((seats) {
                bool isSelected = selectedSeats == seats;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedSeats = seats;
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(colors: [velvetGreen, woodDark])
                          : null,
                      color: isSelected ? null : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? goldAccent : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: goldAccent.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ] : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          seats <= 2 ? Icons.weekend :
                          seats <= 4 ? Icons.chair :
                          seats <= 6 ? Icons.table_restaurant : Icons.group,
                          color: isSelected ? Colors.white : woodDark,
                          size: 24,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '$seats',
                          style: TextStyle(
                            color: isSelected ? Colors.white : woodDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Shape Selection
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Table Shape',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: woodDark,
                ),
              ),
            ),
            SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShapeCard(TableShape.square, Icons.crop_square, 'Square'),
                _buildShapeCard(TableShape.rectangle, Icons.crop_landscape, 'Rectangle'),
                _buildShapeCard(TableShape.round, Icons.circle, 'Round'),
              ],
            ),
            SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addTable,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: velvetGreen,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Add Table',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShapeCard(TableShape shape, IconData icon, String label) {
    bool isSelected = selectedShape == shape;
    return GestureDetector(
      onTap: () => setState(() => selectedShape = shape),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? velvetGreen.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? velvetGreen : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? velvetGreen : Colors.grey.shade500,
              size: 20,
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? velvetGreen : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTable() {
    if (tableNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a table number'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
      shape: selectedShape,
      floor: selectedFloor,
    );

    widget.onTableAdded(newTable);
    Navigator.pop(context);
  }
}