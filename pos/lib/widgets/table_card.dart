import 'package:flutter/material.dart';
import '../models/seat_model.dart';

class TableCard extends StatelessWidget {
  final String tableName;
  final List<SeatModel> seats;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isSelected;

  const TableCard({
    Key? key,
    required this.tableName,
    required this.seats,
    required this.onTap,
    required this.onLongPress,
    this.isSelected = false,
  }) : super(key: key);

  Color _getSeatColor(SeatModel seat) {
    return seat.status ? Colors.green : Colors.grey.shade300;
  }

  Widget _buildSeat(SeatModel seat, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getSeatColor(seat),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2), // thicker seat border
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

    int seatCount = seats.length;
    int topSeats = (seatCount + 1) ~/ 2;
    int bottomSeats = seatCount ~/ 2;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: tableWidth + 30,
        height: tableHeight + 60,
        decoration: isSelected
            ? BoxDecoration(
          border: Border.all(color: Colors.teal, width: 3), // thicker selection border
          borderRadius: BorderRadius.circular(12),
        )
            : null,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal, width: 2.5), // thicker table border
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(2, 2))],
                ),
                child: Center(
                  child: Text(
                    tableName,
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
            // Top seats
            ...List.generate(topSeats, (index) {
              double total = (topSeats * seatSize) + ((topSeats - 1) * seatGap);
              double start = sideMargin + (tableWidth - total) / 2;
              double left = start + index * (seatSize + seatGap);
              return Positioned(top: topMargin, left: left, child: _buildSeat(seats[index], seatSize));
            }),
            // Bottom seats
            ...List.generate(bottomSeats, (index) {
              double total = (bottomSeats * seatSize) + ((bottomSeats - 1) * seatGap);
              double start = sideMargin + (tableWidth - total) / 2;
              double left = start + index * (seatSize + seatGap);
              return Positioned(
                top: topMargin + seatSize + 10 + tableHeight + 15,
                left: left,
                child: _buildSeat(seats[index + topSeats], seatSize),
              );
            }),
          ],
        ),
      ),
    );
  }
}