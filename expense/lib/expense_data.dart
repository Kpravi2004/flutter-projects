class ExpenseData {
  final String date;
  final String category;
  final String expenseName;
  final int amount;
  final String paymentMethod;
  final bool isActive;

  ExpenseData({
    required this.date,
    required this.category,
    required this.expenseName,
    required this.amount,
    required this.paymentMethod,
    required this.isActive,
  });
}
