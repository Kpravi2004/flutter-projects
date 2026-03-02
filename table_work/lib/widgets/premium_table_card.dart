import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../utils/helpers.dart';

class PremiumTableCard extends StatelessWidget {
  final TableModel table;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Color accentColor;
  final Color surfaceColor;

  const PremiumTableCard({
    Key? key,
    required this.table,
    required this.onTap,
    required this.onLongPress,
    required this.accentColor,
    required this.surfaceColor,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (table.status) {
      case TableStatus.free:
        return const Color(0xFF00E676);
      case TableStatus.occupied:
        return const Color(0xFFFF5252);
      case TableStatus.reserved:
        return const Color(0xFFFFB74D);
      case TableStatus.cleaning:
        return const Color(0xFF448AFF);
      case TableStatus.billed:
        return const Color(0xFF7C4DFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getTableIcon(),
                      color: statusColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    table.number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${table.guests}/${table.maxGuests}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  if (table.amount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '₹${table.amount}',
                        style: TextStyle(color: statusColor, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTableIcon() {
    switch (table.shape) {
      case TableShape.square:
        return Icons.crop_square;
      case TableShape.rectangle:
        return Icons.crop_landscape;
      case TableShape.round:
        return Icons.circle;
    }
  }
}