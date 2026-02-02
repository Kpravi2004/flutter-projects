import 'package:flutter/material.dart';
import 'expense_data.dart';

class ExpenseState extends ChangeNotifier {
  final List<ExpenseData> _expenses = [];

  String selectedCategory = 'All';
  String selectedPayment = 'All';

  List<ExpenseData> get filteredExpenses {
    return _expenses.where((e) {
      final categoryOk =
          selectedCategory == 'All' || e.category == selectedCategory;
      final paymentOk =
          selectedPayment == 'All' || e.paymentMethod == selectedPayment;
      return categoryOk && paymentOk;
    }).toList();
  }

  void addExpense(ExpenseData expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void updateExpense(int index, ExpenseData expense) {
    _expenses[index] = expense;
    notifyListeners();
  }

  void deleteExpense(int index) {
    _expenses.removeAt(index);
    notifyListeners();
  }

  void changeCategory(String value) {
    selectedCategory = value;
    notifyListeners();
  }

  void changePayment(String value) {
    selectedPayment = value;
    notifyListeners();
  }
}
