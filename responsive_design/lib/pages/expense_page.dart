import 'package:flutter/material.dart';
import '../model/Expense_model.dart';
import '../widgets/add_expense.dart';
import '../widgets/expense_table.dart';
import '../widgets/filtered_expense.dart';
import '../widgets/edit_expense.dart';
class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final List<Expense> expenses = [];

  List<Expense> filteredExpenses = [];

  String selectedCategory = "All";
  String selectedPayment = "All";

  @override
  void initState() {
    super.initState();
    filteredExpenses = List.from(expenses);
  }

  void applyFilters() {
    List<Expense> result = List.from(expenses);

    if (selectedCategory != "All") {
      result = result
          .where((e) => e.category == selectedCategory)
          .toList();
    }

    if (selectedPayment != "All") {
      result = result
          .where((e) => e.payment == selectedPayment)
          .toList();
    }

    setState(() {
      filteredExpenses = result;
    });
  }

  void openAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (_) => AddExpenseDialog(
        onAdd: (expense) {
          setState(() {
            expenses.add(expense);
          });
          applyFilters();
        },
      ),
    );
  }
  void deleteExpense(int index) {
    setState(() {
      expenses.removeAt(index);
    });
    applyFilters();
  }
  void openEditExpenseDialog(int index) {
    showDialog(
      context: context,
      builder: (_) => EditExpenseDialog(
        expense: expenses[index],
        onSave: (updatedExpense) {
          setState(() {
            expenses[index] = updatedExpense;
          });
          applyFilters();
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Expenses",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: openAddExpenseDialog,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Expense"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              FiltersRow(
                selectedCategory: selectedCategory,
                selectedPayment: selectedPayment,
                onCategoryChanged: (value) {
                  selectedCategory = value;
                  applyFilters();
                },
                onPaymentChanged: (value) {
                  selectedPayment = value;
                  applyFilters();
                },
              ),

              const SizedBox(height: 20),

              ExpenseTable(
                expenses: filteredExpenses,
                onDelete: deleteExpense,
                onEdit: (index) {
                  openEditExpenseDialog(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
