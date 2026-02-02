import 'package:flutter/material.dart';
class Expense {
  final String category;
  final String expense_name;
  final int amount;
  final String payment;
  Expense({
    required this.category,
    required this.expense_name,
    required this.amount,
    required this.payment,
  });
}