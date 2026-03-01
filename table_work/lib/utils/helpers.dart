class Helpers {
  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}