import 'package:flutter/material.dart';

class AppConstants {
  // Dark Color Palette
  static const Color darkBackground = Color(0xFF121212);   // Almost black
  static const Color darkSurface = Color(0xFF1E1E1E);      // Dark grey
  static const Color darkElevated = Color(0xFF2C2C2C);     // Slightly lighter

  // Deep Purple shades
  static const Color deepPurpleDark = Color(0xFF2A1B3D);   // Very dark purple
  static const Color royalPurple = Color(0xFF4A2C5F);      // Rich purple
  static const Color mediumPurple = Color(0xFF6B4E7F);     // Medium purple

  // Accent colors
  static const Color goldAccent = Color(0xFFFFB347);       // Soft gold/orange
  static const Color tealAccent = Color(0xFF2AA9A2);       // Teal for highlights

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);    // Light grey
  static const Color textHint = Color(0xFF808080);         // Mid grey

  // Status colors (adjusted for dark theme)
  static const Color successGreen = Color(0xFF2E7D32);     // Dark green
  static const Color errorRed = Color(0xFFC62828);         // Dark red
  static const Color warningOrange = Color(0xFFEF6C00);    // Dark orange
  static const Color infoBlue = Color(0xFF1565C0);         // Dark blue
  static const Color cleaningBlue = Color(0xFF01579B);     // Darker blue
  static const Color billedPurple = Color(0xFF6A1B9A);     // Dark purple

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [deepPurpleDark, royalPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [royalPurple, mediumPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [goldAccent, Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Spacing constants
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusCircle = 999.0;

  // Font sizes
  static const double fontSizeXs = 10.0;
  static const double fontSizeSm = 12.0;
  static const double fontSizeMd = 14.0;
  static const double fontSizeLg = 16.0;
  static const double fontSizeXl = 18.0;
  static const double fontSizeXxl = 20.0;

  // Font weights
  static const FontWeight fontWeightNormal = FontWeight.normal;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.bold;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Grid configurations
  static const int gridColumnsDesktop = 5;
  static const int gridColumnsMobile = 2;
  static const double gridAspectRatio = 0.95;
}