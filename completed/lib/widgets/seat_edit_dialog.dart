import 'package:flutter/material.dart';
import '../models/seat_model.dart';
import '../utils/constants.dart';

class SeatEditDialog extends StatefulWidget {
  final List<SeatModel> seats;
  final int tableNumber;
  final Function(List<SeatModel>) onSave;

  const SeatEditDialog({
    Key? key,
    required this.seats,
    required this.tableNumber,
    required this.onSave,
  }) : super(key: key);

  @override
  State<SeatEditDialog> createState() => _SeatEditDialogState();
}

class _SeatEditDialogState extends State<SeatEditDialog> {
  late List<SeatModel> _editableSeats;

  @override
  void initState() {
    super.initState();
    // Create a mutable copy of seats
    _editableSeats = widget.seats.map((s) => SeatModel(
      id: s.id,
      seatNo: s.seatNo,
      status: s.status,
      colorCode: s.colorCode,
      tableId: s.tableId,
      billingStatus: s.billingStatus,
    )).toList()..sort((a, b) => a.seatNo.compareTo(b.seatNo));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppConstants.lightSurface,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Configure Seats',
              style: TextStyle(
                color: AppConstants.textPrimary,
                fontSize: AppConstants.fontSizeXl,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Table ${widget.tableNumber} • ${_editableSeats.length} seats',
              style: TextStyle(color: AppConstants.textSecondary, fontSize: AppConstants.fontSizeSm),
            ),
            const SizedBox(height: 16),
            // Headers
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppConstants.tealPrimary.withOpacity(0.3)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(flex: 1, child: Text('Seat', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.tealPrimary))),
                  Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.tealPrimary))),
                  Expanded(flex: 2, child: Text('Billed', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.tealPrimary))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: ListView.separated(
                itemCount: _editableSeats.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppConstants.lightSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _editableSeats[index].status == 'Occupied'
                                  ? AppConstants.successGreen
                                  : _editableSeats[index].status == 'Reserved'
                                  ? AppConstants.warningOrange
                                  : Colors.grey,
                            ),
                            child: Center(
                              child: Text(
                                '${_editableSeats[index].seatNo}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: DropdownButton<String>(
                            value: _editableSeats[index].status,
                            isExpanded: true,
                            underline: Container(),
                            icon: Icon(Icons.arrow_drop_down, color: AppConstants.tealPrimary),
                            items: const [
                              DropdownMenuItem(value: 'Free', child: Text('Free')),
                              DropdownMenuItem(value: 'Occupied', child: Text('Occupied')),
                              DropdownMenuItem(value: 'Reserved', child: Text('Reserved')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _editableSeats[index].status = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Checkbox(
                            value: _editableSeats[index].billingStatus,
                            onChanged: (value) {
                              setState(() {
                                _editableSeats[index].billingStatus = value ?? false;
                              });
                            },
                            activeColor: AppConstants.tealPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: TextStyle(color: AppConstants.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.tealPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      widget.onSave(_editableSeats);
                      Navigator.pop(context);
                    },
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
}