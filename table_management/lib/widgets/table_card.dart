import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class TableCard extends StatelessWidget {
  final TableModel table;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const TableCard({
    Key? key,
    required this.table,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (table.status) {
      case TableStatus.free:
        return AppConstants.freeColor;
      case TableStatus.occupied:
        return AppConstants.occupiedColor;
      case TableStatus.reserved:
        return AppConstants.reservedColor;
      case TableStatus.cleaning:
        return AppConstants.cleaningColor;
      case TableStatus.billed:
        return AppConstants.billedColor;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (table.status) {
      case TableStatus.free:
        return 'Free';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.reserved:
        return 'Reserved';
      case TableStatus.cleaning:
        return 'Cleaning';
      case TableStatus.billed:
        return 'Billed';
      default:
        return '';
    }
  }

  Widget _buildSeatIcons() {
    List<Widget> seats = [];
    int totalSeats = table.maxGuests;

    for (int i = 0; i < totalSeats; i++) {
      seats.add(
        Container(
          width: 6,
          height: 6,
          margin: EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: i < table.guests
                ? _getStatusColor()
                : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      children: seats,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Table Header with status color
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    table.number,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (table.waiterName != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        table.waiterName![0].toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Table Body
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Table representation
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.1),
                        shape: table.shape == TableShape.round
                            ? BoxShape.circle
                            : BoxShape.rectangle,
                        borderRadius: table.shape != TableShape.round
                            ? BorderRadius.circular(6)
                            : null,
                        border: Border.all(
                          color: _getStatusColor(),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          table.shape == TableShape.round
                              ? Icons.circle
                              : table.shape == TableShape.rectangle
                              ? Icons.crop_landscape
                              : Icons.crop_square,
                          color: _getStatusColor(),
                          size: 16,
                        ),
                      ),
                    ),

                    // Guests info
                    if (table.guests > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people,
                            size: 10,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 2),
                          Text(
                            '${table.guests}G',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                    // Seat indicators
                    _buildSeatIcons(),

                    // Amount
                    if (table.amount > 0)
                      Text(
                        Helpers.formatCurrency(table.amount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: AppConstants.successColor,
                        ),
                      ),

                    // Additional info
                    if (table.cleaningTime != null)
                      Text(
                        'Cleaning ${table.cleaningTime}',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 7,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (table.reservedTime != null)
                      Text(
                        table.reservedTime!,
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 7,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}