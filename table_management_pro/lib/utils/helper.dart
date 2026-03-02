
import 'package:flutter/material.dart';
import 'constants.dart';

class Helpers {
  // Format currency
  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  // Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'free':
        return AppConstants.freeColor;
      case 'occupied':
        return AppConstants.occupiedColor;
      case 'reserved':
        return AppConstants.reservedColor;
      case 'cleaning':
        return AppConstants.cleaningColor;
      case 'billed':
        return AppConstants.billedColor;
      default:
        return Colors.grey;
    }
  }

  // Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}