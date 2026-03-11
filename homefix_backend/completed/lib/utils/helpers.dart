import 'package:intl/intl.dart';

class Helpers {
  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}