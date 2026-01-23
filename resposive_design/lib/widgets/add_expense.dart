import 'package:flutter/material.dart';
import '../model/Expense_model.dart';

class AddExpenseDialog extends StatefulWidget {
  final Function(Expense) onAdd;

  const AddExpenseDialog({super.key, required this.onAdd});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final nameController = TextEditingController();
  final amountController = TextEditingController();

  String category = "Food";
  String payment = "Cash";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Expense"),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: category,
              items: const [
                DropdownMenuItem(value: "Food", child: Text("Food")),
                DropdownMenuItem(value: "Travel", child: Text("Travel")),
                DropdownMenuItem(value: "Shopping", child: Text("Shopping")),
              ],
              onChanged: (v) => setState(() => category = v!),
              decoration: const InputDecoration(labelText: "Category"),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Expense Name"),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),
            DropdownButtonFormField<String>(
              value: payment,
              items: const [
                DropdownMenuItem(value: "Cash", child: Text("Cash")),
                DropdownMenuItem(value: "Card", child: Text("Card")),
                DropdownMenuItem(value: "UPI", child: Text("UPI")),
              ],
              onChanged: (v) => setState(() => payment = v!),
              decoration: const InputDecoration(labelText: "Payment"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final expense = Expense(
              category: category,
              expense_name: nameController.text,
              amount: int.parse(amountController.text),
              payment: payment,
            );

            widget.onAdd(expense);
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
