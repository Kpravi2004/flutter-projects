import 'package:flutter/material.dart';

class AppColors {
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkElevated = Color(0xFF2C2C2C);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textHint = Color(0xFF808080);
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color cleaningBlue = Color(0xFF2196F3);
  static const Color billedPurple = Color(0xFF9C27B0);
  static const Color royalPurple = Color(0xFF673AB7);

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF2C2C2C), Color(0xFF1E1E1E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}