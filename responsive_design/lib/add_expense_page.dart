import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expense_state.dart';
import 'expense_data.dart';

class AddExpenseDialog extends StatefulWidget {
  final ExpenseData? expense;
  final int? index;

  const AddExpenseDialog({
    super.key,
    this.expense,
    this.index,
  });

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>(); // 🔥 FORM KEY

  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final dateController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String category = 'Food';
  String paymentMethod = 'Cash';
  bool isActive = true;

  @override
  void initState() {
    super.initState();

    if (widget.expense != null) {
      final e = widget.expense!;
      selectedDate = DateTime.tryParse(e.date) ?? DateTime.now();
      category = e.category;
      paymentMethod = e.paymentMethod;
      isActive = e.isActive;
      nameController.text = e.expenseName;
      amountController.text = e.amount.toString();
    }

    dateController.text = _formattedDate;
  }

  String get _formattedDate =>
      "${selectedDate.day.toString().padLeft(2, '0')}-"
          "${selectedDate.month.toString().padLeft(2, '0')}-"
          "${selectedDate.year}";

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = _formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<ExpenseState>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(20),

          // 🔥 FORM STARTS
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Add Expense',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  /// DATE
                  TextFormField(
                    controller: dateController,
                    readOnly: true,
                    onTap: pickDate,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Date is required' : null,
                  ),
                  const SizedBox(height: 16),

                  /// CATEGORY
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Food', 'Travel', 'Bills']
                        .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => category = v!),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Category required' : null,
                  ),
                  const SizedBox(height: 16),

                  /// EXPENSE NAME
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Expense Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Expense name required';
                      }
                      if (v.trim().length < 3) {
                        return 'Minimum 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  /// AMOUNT
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Amount required';
                      }
                      final num? value = num.tryParse(v);
                      if (value == null) {
                        return 'Enter valid number';
                      }
                      if (value <= 0) {
                        return 'Amount must be > 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  /// PAYMENT METHOD
                  DropdownButtonFormField<String>(
                    value: paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Cash', 'GPay', 'Paytm']
                        .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => paymentMethod = v!),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Payment required' : null,
                  ),

                  /// ACTIVE
                  Row(
                    children: [
                      Checkbox(
                        value: isActive,
                        onChanged: (v) =>
                            setState(() => isActive = v!),
                      ),
                      const Text('Active'),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// ACTION BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // 🔥 VALIDATION TRIGGER
                          if (!_formKey.currentState!.validate()) {
                            return; // ❌ STOP if invalid
                          }

                          final expense = ExpenseData(
                            date: dateController.text,
                            category: category,
                            expenseName: nameController.text.trim(),
                            amount:
                            int.parse(amountController.text),
                            paymentMethod: paymentMethod,
                            isActive: isActive,
                          );

                          widget.index == null
                              ? state.addExpense(expense)
                              : state.updateExpense(
                              widget.index!, expense);

                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
