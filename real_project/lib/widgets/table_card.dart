import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../utils/helpers.dart';

class TableCard extends StatelessWidget {
  final TableModel table;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isSelected; // new parameter

  const TableCard({
    Key? key,
    required this.table,
    required this.onTap,
    required this.onLongPress,
    this.isSelected = false, // default false
  }) : super(key: key);

  Color _getStatusColor() {
    switch (table.status) {
      case TableStatus.free:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.cleaning:
        return Colors.blue;
      case TableStatus.billed:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getSeatColor(int seatIndex) {
    if (seatIndex < table.guests) {
      return Colors.green; // Occupied seats are green
    } else {
      return Colors.grey.shade300; // Empty seats are light grey
    }
  }

  Widget _buildSeat(int seatIndex, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getSeatColor(seatIndex),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fixed table dimensions (as per your latest version)
    double tableWidth = 150;
    double tableHeight = 100;

    // Seat size
    double seatSize = 16;

    // Gap between seats
    double seatGap = 8;

    // Margins from edges
    double topMargin = 20;
    double sideMargin = 15;

    int seatsPerRow = table.maxGuests ~/ 2;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: tableWidth + 30,
        height: tableHeight + 60,
        decoration: isSelected
            ? BoxDecoration(
          border: Border.all(
            color: Colors.amber,
            width: 4,
          ),
          borderRadius: BorderRadius.circular(12),
        )
            : null,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main Table (Rectangle)
            Positioned(
              left: sideMargin,
              top: topMargin + seatSize + 5,
              child: Container(
                width: tableWidth,
                height: tableHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor(),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        table.number,
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (table.amount > 0)
                        Text(
                          Helpers.formatCurrency(table.amount),
                          style: TextStyle(
                            color: _getStatusColor(),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (table.waiterName != null)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            table.waiterName!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Top seats
            ...List.generate(
              seatsPerRow,
                  (index) {
                double totalSeatWidth = (seatsPerRow * seatSize) + ((seatsPerRow - 1) * seatGap);
                double startX = sideMargin + (tableWidth - totalSeatWidth) / 2;
                double leftOffset = startX + index * (seatSize + seatGap);

                return Positioned(
                  top: topMargin,
                  left: leftOffset,
                  child: _buildSeat(index, seatSize),
                );
              },
            ),

            // Bottom seats
            ...List.generate(
              seatsPerRow,
                  (index) {
                double totalSeatWidth = (seatsPerRow * seatSize) + ((seatsPerRow - 1) * seatGap);
                double startX = sideMargin + (tableWidth - totalSeatWidth) / 2;
                double leftOffset = startX + index * (seatSize + seatGap);

                return Positioned(
                  top: topMargin + seatSize + 10 + tableHeight + 15,
                  left: leftOffset,
                  child: _buildSeat(index + seatsPerRow, seatSize),
                );
              },
            ),

            // Multiple bills indicator
            if (table.bills != null && table.bills!.length > 1)
              Positioned(
                top: 5,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${table.bills!.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}