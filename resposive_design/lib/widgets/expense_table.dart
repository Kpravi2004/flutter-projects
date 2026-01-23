import 'package:flutter/material.dart';
import '../model/Expense_model.dart';

class ExpenseTable extends StatelessWidget {
  final List<Expense> expenses;
  final Function(int) onDelete;
  final Function(int) onEdit;

  const ExpenseTable({
    super.key,
    required this.expenses,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text("No expenses added"),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Category")),
          DataColumn(label: Text("Expense")),
          DataColumn(label: Text("Amount")),
          DataColumn(label: Text("Payment")),
          DataColumn(label: Text("Actions")),
        ],
        rows: List.generate(expenses.length, (index) {
          final expense = expenses[index];

          return DataRow(
            cells: [
              DataCell(Text(expense.category)),
              DataCell(Text(expense.expense_name)),
              DataCell(Text("₹ ${expense.amount}")),
              DataCell(Text(expense.payment)),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => onEdit(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDelete(index),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
