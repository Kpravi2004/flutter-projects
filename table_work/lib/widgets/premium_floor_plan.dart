import 'package:flutter/material.dart';
import '../models/table_model.dart';
import 'premium_table_card.dart';

class PremiumFloorPlan extends StatelessWidget {
  final List<TableModel> tables;
  final Function(TableModel) onTableTap;
  final Color accentColor;
  final Color surfaceColor;

  const PremiumFloorPlan({
    Key? key,
    required this.tables,
    required this.onTableTap,
    required this.accentColor,
    required this.surfaceColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FloorPlanPainter(accentColor: accentColor),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            // Floor grid lines
            ..._buildGridLines(),

            // Tables positioned on floor plan
            ...tables.asMap().entries.map((entry) {
              final index = entry.key;
              final table = entry.value;

              // Calculate position based on index (creative layout)
              final row = index ~/ 3;
              final col = index % 3;

              double left = 100 + col * 180 + (row % 2 == 0 ? 0 : 40);
              double top = 100 + row * 160;

              return Positioned(
                left: left,
                top: top,
                child: SizedBox(
                  width: 120,
                  height: 140,
                  child: PremiumTableCard(
                    table: table,
                    onTap: () => onTableTap(table),
                    onLongPress: () => onTableTap(table),
                    accentColor: accentColor,
                    surfaceColor: surfaceColor,
                  ),
                ),
              );
            }).toList(),

            // Section labels
            _buildSectionLabel('Main Dining', 50, 50),
            _buildSectionLabel('VIP Section', 500, 50),
            _buildSectionLabel('Bar Area', 50, 400),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGridLines() {
    List<Widget> lines = [];

    for (int i = 0; i < 10; i++) {
      lines.add(
        Positioned(
          left: 50.0 + i * 80,
          top: 50,
          child: Container(
            width: 1,
            height: 500,
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      );

      lines.add(
        Positioned(
          left: 50,
          top: 50.0 + i * 80,
          child: Container(
            width: 800,
            height: 1,
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      );
    }

    return lines;
  }

  Widget _buildSectionLabel(String label, double left, double top) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: accentColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class FloorPlanPainter extends CustomPainter {
  final Color accentColor;

  FloorPlanPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw floor plan outlines
    final path = Path();

    // Main dining area
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(40, 40, size.width - 80, size.height - 80),
      const Radius.circular(20),
    ));

    // VIP section
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - 300, 60, 240, 200),
      const Radius.circular(16),
    ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}