import 'package:flutter/material.dart';
import '../models/seat_model.dart';
import '../utils/constants.dart';

class SeatSelectionDialog extends StatefulWidget {
  final List<SeatModel> seats;
  final int maxGuests;
  final int tableNumber;
  final Function(List<SeatModel>) onSeatsSelected;

  const SeatSelectionDialog({
    Key? key,
    required this.seats,
    required this.maxGuests,
    required this.tableNumber,
    required this.onSeatsSelected,
  }) : super(key: key);

  @override
  State<SeatSelectionDialog> createState() => _SeatSelectionDialogState();
}

class _SeatSelectionDialogState extends State<SeatSelectionDialog> {
  late List<SeatModel> _selectedSeats;
  int _occupiedCount = 0;

  @override
  void initState() {
    super.initState();
    // Start with all seats free
    _selectedSeats = widget.seats.map((s) => SeatModel(
      id: s.id,
      seatNo: s.seatNo,
      status: 'Free',
      colorCode: 'White',
      tableId: s.tableId,
    )).toList();
  }

  void _toggleSeat(int index) {
    setState(() {
      if (_selectedSeats[index].status == 'Free') {
        _selectedSeats[index].status = 'Occupied';
        _occupiedCount++;
      } else {
        _selectedSeats[index].status = 'Free';
        _occupiedCount--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppConstants.lightSurface,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Occupied Seats',
              style: TextStyle(
                color: AppConstants.textPrimary,
                fontSize: AppConstants.fontSizeXl,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Table ${widget.tableNumber} • Tap seats to mark occupied',
              style: TextStyle(color: AppConstants.textSecondary, fontSize: AppConstants.fontSizeSm),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_selectedSeats.length, (index) {
                bool isOccupied = _selectedSeats[index].status == 'Occupied';
                return GestureDetector(
                  onTap: () => _toggleSeat(index),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isOccupied ? AppConstants.successGreen : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isOccupied ? Colors.white : Colors.grey.shade400,
                        width: 2,
                      ),
                      boxShadow: isOccupied
                          ? [BoxShadow(color: AppConstants.successGreen.withOpacity(0.3), blurRadius: 8)]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${_selectedSeats[index].seatNo}',
                        style: TextStyle(
                          color: isOccupied ? Colors.white : AppConstants.textPrimary,
                          fontSize: AppConstants.fontSizeMd,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: AppConstants.lightSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people, color: AppConstants.tealPrimary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$_occupiedCount / ${widget.maxGuests} occupied',
                    style: TextStyle(
                      color: AppConstants.textPrimary,
                      fontSize: AppConstants.fontSizeMd,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.tealPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      widget.onSeatsSelected(_selectedSeats);
                      Navigator.pop(context);
                    },
                    child: const Text('Confirm'),
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