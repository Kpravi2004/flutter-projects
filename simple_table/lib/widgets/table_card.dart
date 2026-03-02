import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';

class TableCard extends StatelessWidget {
  final TableModel table;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isSelected;

  const TableCard({
    Key? key,
    required this.table,
    required this.onTap,
    required this.onLongPress,
    this.isSelected = false,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (table.status) {
      case TableStatus.free: return AppConstants.successGreen;
      case TableStatus.occupied: return AppConstants.errorRed;
      case TableStatus.reserved: return AppConstants.warningOrange;
      case TableStatus.cleaning: return AppConstants.cleaningBlue;
      case TableStatus.billed: return AppConstants.billedPurple;
      default: return Colors.grey;
    }
  }

  Color _getSeatColor(int seatIndex) {
    if (seatIndex < table.seats.length) {
      return table.seats[seatIndex].status == 'Occupied' ? AppConstants.successGreen : Colors.grey.shade300;
    }
    return seatIndex < table.guests ? AppConstants.successGreen : Colors.grey.shade300;
  }

  Widget _buildSeat(int seatIndex, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getSeatColor(seatIndex),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: AppConstants.borderNormal),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: const Offset(1, 1))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double tableWidth = 150;
    double tableHeight = 100;
    double seatSize = 18;
    double seatGap = 8;
    double topMargin = 20;
    double sideMargin = 15;

    int topSeats = (table.maxGuests + 1) ~/ 2;
    int bottomSeats = table.maxGuests ~/ 2;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: tableWidth + 30,
        height: tableHeight + 60,
        decoration: isSelected ? BoxDecoration(border: Border.all(color: AppConstants.tealPrimary, width: AppConstants.borderThick * 2), borderRadius: BorderRadius.circular(12)) : null,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main Table
            Positioned(
              left: sideMargin,
              top: topMargin + seatSize + 5,
              child: Container(
                width: tableWidth,
                height: tableHeight,
                decoration: BoxDecoration(
                  color: AppConstants.lightSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getStatusColor(), width: AppConstants.borderThick),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(2, 2))],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(table.number, style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.bold, fontSize: AppConstants.fontSizeLg)),
                      if (table.amount > 0) Text(Helpers.formatCurrency(table.amount), style: TextStyle(color: _getStatusColor(), fontSize: AppConstants.fontSizeSm, fontWeight: FontWeight.bold)),
                      if (table.waiterName != null)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: _getStatusColor(), borderRadius: BorderRadius.circular(8)),
                          child: Text(table.waiterName!, style: const TextStyle(color: Colors.white, fontSize: AppConstants.fontSizeXs, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Top seats
            ...List.generate(topSeats, (index) {
              double total = (topSeats * seatSize) + ((topSeats - 1) * seatGap);
              double start = sideMargin + (tableWidth - total) / 2;
              double left = start + index * (seatSize + seatGap);
              return Positioned(top: topMargin, left: left, child: _buildSeat(index, seatSize));
            }),

            // Bottom seats
            ...List.generate(bottomSeats, (index) {
              double total = (bottomSeats * seatSize) + ((bottomSeats - 1) * seatGap);
              double start = sideMargin + (tableWidth - total) / 2;
              double left = start + index * (seatSize + seatGap);
              return Positioned(top: topMargin + seatSize + 10 + tableHeight + 15, left: left, child: _buildSeat(index + topSeats, seatSize));
            }),

            // Multiple bills indicator
            if (table.bills != null && table.bills!.length > 1)
              Positioned(
                top: 5,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppConstants.billedPurple, borderRadius: BorderRadius.circular(10)),
                  child: Text('${table.bills!.length}', style: const TextStyle(color: Colors.white, fontSize: AppConstants.fontSizeXs, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}