import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../models/seat_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class SeatConfigDialog extends StatefulWidget {
  final TableModel table;
  final int totalSeats;

  const SeatConfigDialog({
    Key? key,
    required this.table,
    required this.totalSeats,
  }) : super(key: key);

  @override
  State<SeatConfigDialog> createState() => _SeatConfigDialogState();
}

class _SeatConfigDialogState extends State<SeatConfigDialog> {
  late List<SeatModel> seats;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    seats = List.generate(
      widget.totalSeats,
          (index) => SeatModel(
        id: 0,
        seatNo: index + 1,
        status: 'Free',
        colorCode: 'White',
        tableId: widget.table.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Configure Seats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Table ${widget.table.number} (${widget.totalSeats} seats)',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: seats.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text('Seat ${index + 1}'),
                      trailing: DropdownButton<String>(
                        value: seats[index].status,
                        items: const [
                          DropdownMenuItem(value: 'Free', child: Text('Free')),
                          DropdownMenuItem(value: 'Occupied', child: Text('Occupied')),
                          DropdownMenuItem(value: 'Reserved', child: Text('Reserved')),
                        ],
                        onChanged: _isSaving
                            ? null
                            : (value) {
                          setState(() {
                            seats[index].status = value!;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),
            if (_isSaving)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveSeats,
                      child: const Text('Save Seats'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSeats() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      for (var seat in seats) {
        await ApiService.createSeat(
          tableId: widget.table.id,
          seatNo: seat.seatNo,
          status: seat.status,
          colorCode: seat.colorCode,
        );
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error creating seats: $e');
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Failed to create seats. Please try again.';
        });
      }
    }
  }
}