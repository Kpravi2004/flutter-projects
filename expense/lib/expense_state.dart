import 'package:flutter/material.dart';
import 'expense_data.dart';

class ExpenseState extends ChangeNotifier {
  final List<ExpenseData> _expenses = [];

  String selectedCategory = 'All';
  String selectedPayment = 'All';

  DateTime? fromDate;
  DateTime? toDate;

  int currentPage = 1;
  int pageSize = 5;

  List<ExpenseData> get filteredExpenses {
    return _expenses.where((e) {
      final categoryOk =
          selectedCategory == 'All' || e.category == selectedCategory;
      final paymentOk =
          selectedPayment == 'All' || e.paymentMethod == selectedPayment;

      final d = DateTime.tryParse(e.date);

      final fromOk =
          fromDate == null || (d != null && !d.isBefore(fromDate!));
      final toOk = toDate == null || (d != null && !d.isAfter(toDate!));

      return categoryOk && paymentOk && fromOk && toOk;
    }).toList();
  }

  List<ExpenseData> get paginatedExpenses {
    final start = (currentPage - 1) * pageSize;
    final end = start + pageSize;
    final list = filteredExpenses;

    return list.sublist(
      start,
      end > list.length ? list.length : end,
    );
  }

  void addExpense(ExpenseData e) {
    _expenses.add(e);
    notifyListeners();
  }

  void updateExpense(int index, ExpenseData e) {
    _expenses[index] = e;
    notifyListeners();
  }

  void deleteExpense(int index) {
    _expenses.removeAt(index);
    notifyListeners();
  }

  void changeCategory(String v) {
    selectedCategory = v;
    currentPage = 1;
    notifyListeners();
  }

  void changePayment(String v) {
    selectedPayment = v;
    currentPage = 1;
    notifyListeners();
  }

  void setFromDate(DateTime d) {
    fromDate = d;
    currentPage = 1;
    notifyListeners();
  }

  void setToDate(DateTime? d) {
    toDate = d;
    currentPage = 1;
    notifyListeners();
  }

  void setPageSize(int size) {
    pageSize = size;
    currentPage = 1;
    notifyListeners();
  }

  void nextPage() {
    if ((currentPage * pageSize) < filteredExpenses.length) {
      currentPage++;
      notifyListeners();
    }
  }

  void prevPage() {
    if (currentPage > 1) {
      currentPage--;
      notifyListeners();
    }
  }
}
