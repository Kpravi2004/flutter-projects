import 'package:flutter/material.dart';

class PremiumStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;
  final String? change;
  final String? subtitle;

  const PremiumStatsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientColors,
    this.change,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors.map((c) => c.withOpacity(0.1)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradientColors.first.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
              ),
              Icon(icon, color: gradientColors.first, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (change != null) ...[
            const SizedBox(height: 4),
            Text(change!, style: TextStyle(color: gradientColors.first, fontSize: 10)),
          ],
        ],
      ),
    );
  }
}