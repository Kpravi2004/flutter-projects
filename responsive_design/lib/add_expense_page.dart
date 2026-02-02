import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'expense_state.dart';
import 'expense_data.dart';

class AddExpensePage extends StatefulWidget {
  final ExpenseData? expense;
  final int? index;

  const AddExpensePage({super.key, this.expense, this.index});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

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
  }

  String get formattedDate =>
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
    if (picked != null) setState(() => selectedDate = picked);
  }

  OutlineInputBorder borderStyle() =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(6));

  /// 🔥 COMMON SPACING FOR ALL INPUT FIELDS
  Widget fieldSpacing({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12), // 👈 change here
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ExpenseState>(context, listen: false);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Add Expense'),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100, minWidth: 700),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              height: screenHeight * 0.65,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ROW 1 — DATE + CATEGORY
                    Row(
                      children: [
                        Expanded(
                          child: fieldSpacing(
                            child: TextField(
                              readOnly: true,
                              onTap: pickDate,
                              decoration: InputDecoration(
                                labelText: 'Date',
                                suffixIcon:
                                const Icon(Icons.calendar_today),
                                border: borderStyle(),
                              ),
                              controller: TextEditingController(
                                text: formattedDate,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: fieldSpacing(
                            child: DropdownButtonFormField(
                              value: category,
                              decoration: InputDecoration(
                                labelText: 'Category',
                                border: borderStyle(),
                              ),
                              items: ['Food', 'Travel', 'Bills']
                                  .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => category = v!),
                            ),
                          ),
                        ),
                      ],
                    ),

                    /// ROW 2 — EXPENSE NAME + AMOUNT
                    Row(
                      children: [
                        Expanded(
                          child: fieldSpacing(
                            child: TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'Expense Name',
                                hintText: 'Expense Name',
                                border: borderStyle(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: fieldSpacing(
                            child: TextField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                hintText: 'Amount',
                                border: borderStyle(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    /// ROW 3 — PAYMENT + ACTIVE
                    Row(
                      children: [
                        Expanded(
                          child: fieldSpacing(
                            child: DropdownButtonFormField(
                              value: paymentMethod,
                              decoration: InputDecoration(
                                labelText: 'Payment Method',
                                border: borderStyle(),
                              ),
                              items: ['Cash', 'GPay', 'Paytm']
                                  .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => paymentMethod = v!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: fieldSpacing(
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isActive,
                                  onChanged: (v) =>
                                      setState(() => isActive = v!),
                                ),
                                const Text('Active'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    /// ACTION BUTTONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            final expense = ExpenseData(
                              date: formattedDate,
                              category: category,
                              expenseName: nameController.text,
                              amount: int.tryParse(
                                  amountController.text) ??
                                  0,
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
      ),
    );
  }
}
