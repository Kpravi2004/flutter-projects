import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../utils/constants.dart';
import '../utils/helper.dart';

class TableCard extends StatelessWidget {
  final TableModel table;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isSelected; // New parameter for selection state

  const TableCard({
    Key? key,
    required this.table,
    required this.onTap,
    required this.onLongPress,
    this.isSelected = false, // Default to false
  }) : super(key: key);

  // Elegant color palette
  static const Color woodLight = Color(0xFFDEB887);
  static const Color woodMedium = Color(0xFFC19A6B);
  static const Color woodDark = Color(0xFF8B5A2B);
  static const Color marbleWhite = Color(0xFFF8F8FF);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color velvetGreen = Color(0xFF2E5C4E);
  static const Color velvetBurgundy = Color(0xFF800020);
  static const Color velvetNavy = Color(0xFF1A2F4F);
  static const Color selectionPink = Color(0xFFFF69B4); // Hot pink for selection

  Color _getStatusColor() {
    if (isSelected) return selectionPink; // Pink when selected

    switch (table.status) {
      case TableStatus.free:
        return Colors.green.shade600;
      case TableStatus.occupied:
        return Colors.red.shade600;
      case TableStatus.reserved:
        return Colors.orange.shade600;
      case TableStatus.cleaning:
        return Colors.blue.shade600;
      case TableStatus.billed:
        return Colors.purple.shade600;
      default:
        return Colors.grey;
    }
  }

  Color _getSeatColor(int seatIndex) {
    if (isSelected) {
      // When table is selected, show pink for all seats
      return selectionPink.withOpacity(0.7);
    }

    if (seatIndex < table.guests) {
      // Occupied seats - elegant velvet colors
      List<Color> occupiedColors = [velvetGreen, velvetBurgundy, velvetNavy];
      return occupiedColors[seatIndex % occupiedColors.length];
    } else {
      // Available seats - light elegant color
      return const Color(0xFFE8DFD0); // Cream color for empty seats
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
          width: isSelected ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? selectionPink.withOpacity(0.5) : Colors.black.withOpacity(0.2),
            blurRadius: isSelected ? 4 : 2,
            spreadRadius: isSelected ? 1 : 0,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic table sizing based on number of seats
    double tableSize;
    if (table.maxGuests <= 2) tableSize = 65;
    else if (table.maxGuests <= 4) tableSize = 80;
    else if (table.maxGuests <= 6) tableSize = 95;
    else tableSize = 110;

    double seatSize = 12;
    int seatsPerSide = table.maxGuests ~/ 2;
    double seatSpacing = 6;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: tableSize + 40,
        height: tableSize + 50,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main Table
            Positioned(
              left: 20,
              top: 20,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: tableSize,
                height: tableSize,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      marbleWhite,
                      const Color(0xFFE8D8C0),
                    ],
                    center: Alignment.center,
                    radius: 0.8,
                  ),
                  shape: table.shape == TableShape.round
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                  borderRadius: table.shape != TableShape.round
                      ? BorderRadius.circular(table.shape == TableShape.square ? 12 : 8)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? selectionPink.withOpacity(0.3) : Colors.black.withOpacity(0.15),
                      blurRadius: isSelected ? 8 : 6,
                      spreadRadius: isSelected ? 2 : 0,
                    ),
                  ],
                  border: Border.all(
                    color: _getStatusColor(),
                    width: isSelected ? 3 : 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        table.number,
                        style: TextStyle(
                          color: woodDark,
                          fontWeight: FontWeight.bold,
                          fontSize: table.maxGuests <= 4 ? 14 : 16,
                        ),
                      ),
                      if (table.amount > 0)
                        Text(
                          Helpers.formatCurrency(table.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: _getStatusColor(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Top seats - positioned above the table
            ...List.generate(
              seatsPerSide,
                  (index) {
                double totalSeatWidth = (seatsPerSide * seatSize) + ((seatsPerSide - 1) * seatSpacing);
                double startX = 20 + (tableSize - totalSeatWidth) / 2;
                double leftOffset = startX + index * (seatSize + seatSpacing);

                return Positioned(
                  top: 12,
                  left: leftOffset,
                  child: _buildSeat(index, seatSize),
                );
              },
            ),

            // Bottom seats - positioned below the table
            ...List.generate(
              seatsPerSide,
                  (index) {
                double totalSeatWidth = (seatsPerSide * seatSize) + ((seatsPerSide - 1) * seatSpacing);
                double startX = 20 + (tableSize - totalSeatWidth) / 2;
                double leftOffset = startX + index * (seatSize + seatSpacing);

                return Positioned(
                  top: 20 + tableSize + 8,
                  left: leftOffset,
                  child: _buildSeat(index + seatsPerSide, seatSize),
                );
              },
            ),

            // Left side seats (only for tables with more than 4 seats)
            if (table.maxGuests > 4)
              ...List.generate(
                2,
                    (index) {
                  double topOffset = 20 + (index * (tableSize / 3)) + 10;
                  return Positioned(
                    left: 10,
                    top: topOffset,
                    child: _buildSeat(index + (seatsPerSide * 2), seatSize),
                  );
                },
              ),

            // Right side seats (only for tables with more than 4 seats)
            if (table.maxGuests > 4)
              ...List.generate(
                2,
                    (index) {
                  double topOffset = 20 + (index * (tableSize / 3)) + 10;
                  return Positioned(
                    left: 20 + tableSize + 10,
                    top: topOffset,
                    child: _buildSeat(index + (seatsPerSide * 2) + 2, seatSize),
                  );
                },
              ),

            // Waiter indicator
            if (table.waiterName != null && !isSelected)
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: goldAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    table.waiterName![0],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Multiple bills indicator
            if (table.bills != null && table.bills!.length > 1 && !isSelected)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${table.bills!.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7,
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