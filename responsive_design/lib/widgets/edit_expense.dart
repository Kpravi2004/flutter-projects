import 'package:flutter/material.dart';
import '../model/Expense_model.dart';

class EditExpenseDialog extends StatefulWidget {
  final Expense expense;
  final Function(Expense) onSave;

  const EditExpenseDialog({
    super.key,
    required this.expense,
    required this.onSave,
  });

  @override
  State<EditExpenseDialog> createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends State<EditExpenseDialog> {
  late TextEditingController nameController;
  late TextEditingController amountController;

  late String category;
  late String payment;

  @override
  void initState() {
    super.initState();

    // 🔹 pre-fill data
    nameController = TextEditingController(text: widget.expense.expense_name);
    amountController =
        TextEditingController(text: widget.expense.amount.toString());

    category = widget.expense.category;
    payment = widget.expense.payment;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Expense"),
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
            final updatedExpense = Expense(
              category: category,
              expense_name: nameController.text,
              amount: int.parse(amountController.text),
              payment: payment,
            );

            widget.onSave(updatedExpense);
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
