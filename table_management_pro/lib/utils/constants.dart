import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Colors.blue;
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;
  static const Color freeColor = Colors.green;
  static const Color occupiedColor = Colors.red;
  static const Color reservedColor = Colors.orange;
  static const Color cleaningColor = Colors.blue;
  static const Color billedColor = Colors.purple;

  // Status text
  static const String statusFree = 'Free';
  static const String statusOccupied = 'Occupied';
  static const String statusReserved = 'Reserved';
  static const String statusCleaning = 'Cleaning';
  static const String statusBilled = 'Billed';

  // Shared Preferences Keys
  static const String prefTables = 'saved_tables';
  static const String prefWaiters = 'saved_waiters';
}