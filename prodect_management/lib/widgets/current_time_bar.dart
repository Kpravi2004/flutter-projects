import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/helpers.dart';

class CurrentTimeBar extends StatefulWidget {
  const CurrentTimeBar({super.key});

  @override
  State<CurrentTimeBar> createState() => _CurrentTimeBarState();
}

class _CurrentTimeBarState extends State<CurrentTimeBar> {
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updateTime());
  }

  void _updateTime() {
    if (mounted) setState(() => _now = DateTime.now());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppColors.surfaceLight,
      child: Row(
        children: [
          // Plain text – no gradient
          Text(
            'SENTINIX',
            style: const TextStyle(
              color: AppColors.primaryPink,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.surfaceMedium, AppColors.surfaceLight],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryPink.withOpacity(0.3),
                width: 1.5, // slightly thicker border
              ),
            ),
            child: Text(
              formatTime(_now),
              style: const TextStyle(
                color: AppColors.primaryPink,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}