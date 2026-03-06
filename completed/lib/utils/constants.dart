import 'package:flutter/material.dart';

class AppConstants {
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFFAFAFA);

  static const Color tealPrimary = Color(0xFF2A9D8F);
  static const Color tealLight = Color(0xFFE9F0EF);
  static const Color tealDark = Color(0xFF1E6F64);

  static const Color coralAccent = Color(0xFFF4A261);
  static const Color coralLight = Color(0xFFFEF3E9);
  static const Color coralDark = Color(0xFFE76F51);

  static const Color goldAccent = Color(0xFFE9C46A);

  static const Color textPrimary = Color(0xFF2D3E50);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  static const Color successGreen = Color(0xFF2E7D32);
  static const Color errorRed = Color(0xFFC62828);
  static const Color warningOrange = Color(0xFFEF6C00);
  static const Color infoBlue = Color(0xFF1565C0);
  static const Color cleaningBlue = Color(0xFF01579B);
  static const Color billedPurple = Color(0xFF6A1B9A);

  static const double borderThin = 3.0;
  static const double borderNormal = 4.0;
  static const double borderThick = 5.0;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [tealLight, tealPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [coralLight, coralAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusCircle = 999.0;

  static const double fontSizeXs = 11.0;
  static const double fontSizeSm = 13.0;
  static const double fontSizeMd = 15.0;
  static const double fontSizeLg = 17.0;
  static const double fontSizeXl = 19.0;
  static const double fontSizeXxl = 21.0;

  static const FontWeight fontWeightNormal = FontWeight.normal;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.bold;

  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  static const int gridColumnsDesktop = 5;
  static const int gridColumnsMobile = 2;
  static const double gridAspectRatio = 0.95;
}