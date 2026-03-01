import 'package:flutter/material.dart';

class PremiumAnalyticsChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Color accentColor;

  const PremiumAnalyticsChart({
    Key? key,
    required this.data,
    required this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Peak Hours Analysis',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: ChartPainter(
                data: data,
                accentColor: accentColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildStatsSummary(),
      ],
    );
  }

  Widget _buildStatsSummary() {
    double avgOccupancy = data.fold(0, (sum, item) => sum + (item['occupancy'] as int)) / data.length;
    int peakHour = data.reduce((a, b) => (a['occupancy'] > b['occupancy'] ? a : b))['hour'];
    int peakValue = data.reduce((a, b) => (a['occupancy'] > b['occupancy'] ? a : b))['occupancy'];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStatRow('Average Occupancy', '${avgOccupancy.toStringAsFixed(1)}%', accentColor),
          const SizedBox(height: 12),
          _buildStatRow('Peak Hour', peakHour, Colors.amber),
          const SizedBox(height: 12),
          _buildStatRow('Peak Occupancy', '$peakValue%', Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class ChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final Color accentColor;

  ChartPainter({required this.data, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fillPaint = Paint()
      ..color = accentColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    if (data.isEmpty) return;

    final double width = size.width;
    final double height = size.height;
    final double barWidth = width / data.length - 10;

    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i * (width / data.length)) + 10;
      final y = height - (data[i]['occupancy'] / 100 * height * 0.8) - 20;

      // Draw bar
      final barPath = Path();
      barPath.addRect(Rect.fromLTWH(
        x,
        y,
        barWidth,
        height - y - 20,
      ));
      canvas.drawPath(barPath, fillPaint);

      // Draw bar border
      canvas.drawRect(
        Rect.fromLTWH(x, y, barWidth, height - y - 20),
        paint,
      );

      // Draw point
      canvas.drawCircle(
        Offset(x + barWidth / 2, y),
        4,
        pointPaint,
      );

      // Draw label
      _drawLabel(canvas, data[i]['hour'], Offset(x + barWidth / 2, height - 10));
    }
  }

  void _drawLabel(Canvas canvas, String label, Offset position) {
    final textSpan = TextSpan(
      text: label,
      style: const TextStyle(color: Colors.white70, fontSize: 10),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}