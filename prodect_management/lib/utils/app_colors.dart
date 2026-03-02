import 'package:flutter/material.dart';

class AppColors {
  // Background – clean white
  static const Color background = Color(0xFFFFFFFF);

  // Surface colors – light grays for cards and elevation
  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color surfaceMedium = Color(0xFFEEEEEE);
  static const Color surfaceDark = Color(0xFFE0E0E0);

  // Text colors – dark for readability
  static const Color textPrimary = Color(0xFF212121);    // dark gray
  static const Color textSecondary = Color(0xFF757575);  // medium gray
  static const Color textHint = Color(0xFFBDBDBD);       // light gray

  // Pink accent palette
  static const Color primaryPink = Color(0xFFE91E63);    // Material Pink 500
  static const Color primaryLight = Color(0xFFF06292);   // Pink 300
  static const Color primaryDark = Color(0xFFC2185B);    // Pink 700
  static const Color accentPink = Color(0xFFFF80AB);     // Light pink

  // Status colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color infoBlue = Color(0xFF2196F3);

  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFFF06292), Color(0xFFE91E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF5F5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}