import 'package:flutter/material.dart';
import '../models/seat_model.dart';
import '../utils/constants.dart';

class SeatSelectionDialog extends StatefulWidget {
  final List<SeatModel> seats;
  final int maxGuests;
  final int tableNumber;
  final bool allowToggleOccupied;
  final Function(List<SeatModel>) onSeatsSelected;

  const SeatSelectionDialog({
    Key? key,
    required this.seats,
    required this.maxGuests,
    required this.tableNumber,
    this.allowToggleOccupied = false,
    required this.onSeatsSelected,
  }) : super(key: key);

  @override
  State<SeatSelectionDialog> createState() => _SeatSelectionDialogState();
}

class _SeatSelectionDialogState extends State<SeatSelectionDialog> {
  final Set<String> _selectedSeatIds = {};

  @override
  Widget build(BuildContext context) {
    int willBeOccupied = widget.seats.where((s) => s.status == 'Occupied').length + _selectedSeatIds.length;

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
              widget.allowToggleOccupied ? 'Select Seats' : 'Add Guests',
              style: TextStyle(
                color: AppConstants.textPrimary,
                fontSize: AppConstants.fontSizeXl,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Table ${widget.tableNumber} • Tap free seats to select',
              style: TextStyle(color: AppConstants.textSecondary, fontSize: AppConstants.fontSizeSm),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(widget.seats.length, (index) {
                final seat = widget.seats[index];
                final bool isOccupied = seat.status == 'Occupied';
                final bool isFree = seat.status == 'Free';
                final bool isSelected = _selectedSeatIds.contains(seat.id);

                Color bgColor;
                if (isOccupied) {
                  bgColor = AppConstants.errorRed; // occupied seats are red
                } else if (isSelected) {
                  bgColor = AppConstants.successGreen; // temporarily selected free seats are green
                } else {
                  bgColor = Colors.grey.shade200; // free and not selected
                }

                bool canTap = isFree; // only free seats can be toggled
                if (widget.allowToggleOccupied && isOccupied) canTap = true;

                return GestureDetector(
                  onTap: canTap
                      ? () {
                    setState(() {
                      if (isSelected) {
                        _selectedSeatIds.remove(seat.id);
                      } else {
                        _selectedSeatIds.add(seat.id);
                      }
                    });
                  }
                      : null,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : (isOccupied ? Colors.white : Colors.grey.shade400),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${seat.seatNo}',
                        style: TextStyle(
                          color: (isOccupied || isSelected) ? Colors.white : AppConstants.textPrimary,
                          fontSize: AppConstants.fontSizeMd,
                          fontWeight: isOccupied || isSelected ? FontWeight.bold : FontWeight.normal,
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
                    '$willBeOccupied / ${widget.maxGuests} occupied',
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
                      List<SeatModel> updatedSeats = widget.seats.map((seat) {
                        if (_selectedSeatIds.contains(seat.id)) {
                          return SeatModel(
                            id: seat.id,
                            seatNo: seat.seatNo,
                            status: 'Occupied',
                            colorCode: seat.colorCode,
                            tableId: seat.tableId,
                            billingStatus: seat.billingStatus,
                          );
                        } else {
                          return SeatModel(
                            id: seat.id,
                            seatNo: seat.seatNo,
                            status: seat.status,
                            colorCode: seat.colorCode,
                            tableId: seat.tableId,
                            billingStatus: seat.billingStatus,
                          );
                        }
                      }).toList();
                      widget.onSeatsSelected(updatedSeats);
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
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