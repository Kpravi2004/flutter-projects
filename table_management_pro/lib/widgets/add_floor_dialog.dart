import 'package:flutter/material.dart';

class AddFloorDialog extends StatefulWidget {
  final Function(String) onFloorAdded;

  const AddFloorDialog({
    Key? key,
    required this.onFloorAdded,
  }) : super(key: key);

  @override
  _AddFloorDialogState createState() => _AddFloorDialogState();
}

class _AddFloorDialogState extends State<AddFloorDialog> {
  final TextEditingController floorController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_business, color: Colors.green, size: 30),
            ),
            SizedBox(height: 12),

            // Title
            Text(
              'Add New Floor',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0a1929),
              ),
            ),
            SizedBox(height: 16),

            // Floor Name Field
            TextField(
              controller: floorController,
              decoration: InputDecoration(
                labelText: 'Floor Name',
                hintText: 'e.g., Third Floor, Rooftop, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.location_on, color: Colors.green),
              ),
              autofocus: true,
            ),
            SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addFloor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Add Floor',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

  void _addFloor() {
    if (floorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a floor name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onFloorAdded(floorController.text.trim());
    Navigator.pop(context);
  }
}