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
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      color: AppConstants.lightSurface,
      child: Row(
        children: [
          Text(
            'SENTINIX',
            style: TextStyle(
              color: AppConstants.tealPrimary,
              fontSize: AppConstants.fontSizeLg,
              fontWeight: AppConstants.fontWeightBold,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingXs,
            ),
            decoration: BoxDecoration(
              gradient: AppConstants.primaryGradient,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: Border.all(
                color: AppConstants.tealPrimary.withOpacity(0.3),
                width: AppConstants.borderThin,
              ),
            ),
            child: Text(
              formatTime(_now),
              style: TextStyle(
                color: AppConstants.textPrimary,
                fontSize: AppConstants.fontSizeSm,
                fontWeight: AppConstants.fontWeightBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}