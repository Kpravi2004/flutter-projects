import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'expense_state.dart';
import 'add_expense_page.dart';

class ExpenseListPage extends StatelessWidget {
  const ExpenseListPage({super.key});

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final state = context.read<ExpenseState>();

    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? DateTime.now()
          : (state.fromDate ?? DateTime.now()),
      firstDate: isFrom
          ? DateTime(2020)
          : (state.fromDate ?? DateTime(2020)),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      if (isFrom) {
        state.setFromDate(picked);

        if (state.toDate != null && state.toDate!.isBefore(picked)) {
          state.setToDate(null);
        }
      } else {
        state.setToDate(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExpenseState>();
    final expenses = state.paginatedExpenses;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Expenses'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const AddExpenseDialog(),
                );
              },
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔹 FILTER BAR
            Row(
              children: [
                SizedBox(
                  width: 250,
                  child: TextField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'From Date',
                      suffixIcon: Icon(Icons.date_range),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    controller: TextEditingController(
                      text: state.fromDate == null
                          ? ''
                          : _formatDate(state.fromDate!),
                    ),
                    onTap: () => _pickDate(context, true),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 250,
                  child: TextField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'To Date',
                      suffixIcon: Icon(Icons.date_range),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    controller: TextEditingController(
                      text: state.toDate == null
                          ? ''
                          : _formatDate(state.toDate!),
                    ),
                    onTap: state.fromDate == null
                        ? null
                        : () => _pickDate(context, false),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 250,
                  child: DropdownButtonFormField<String>(
                    value: state.selectedCategory,
                    isDense: true,
                    decoration: const InputDecoration(
                      labelText: 'All Categories',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: ['All', 'Food', 'Travel', 'Bills']
                        .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ))
                        .toList(),
                    onChanged: (v) => state.changeCategory(v!),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 250,
                  child: DropdownButtonFormField<String>(
                    value: state.selectedPayment,
                    isDense: true,
                    decoration: const InputDecoration(
                      labelText: 'All Payments',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: ['All', 'Cash', 'GPay', 'Paytm']
                        .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ))
                        .toList(),
                    onChanged: (v) => state.changePayment(v!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 🔹 TABLE / MOBILE VIEW
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  /// 📱 SMALL SCREEN (<300px)
                  if (constraints.maxWidth < 300) {
                    return expenses.isEmpty
                        ? const Center(child: Text('No expenses found'))
                        : ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final e = expenses[index];
                        return _mobileExpenseCard(
                          context,
                          state,
                          e,
                          index,
                        );
                      },
                    );
                  }

                  /// 🖥️ WEB / DESKTOP VIEW (UNCHANGED)
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _tableHeader(),
                        const Divider(height: 1),
                        Expanded(
                          child: expenses.isEmpty
                              ? const Center(
                            child: Text('No expenses found'),
                          )
                              : ListView.builder(
                            itemCount: expenses.length,
                            itemBuilder: (context, index) {
                              final e = expenses[index];
                              return _tableRow(
                                context,
                                state,
                                e,
                                index,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            /// 🔹 ROWS + PAGINATION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Rows per page:'),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: DropdownButtonFormField<int>(
                        value: state.pageSize,
                        isDense: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        ),
                        items: const [
                          DropdownMenuItem(value: 5, child: Text('5')),
                          DropdownMenuItem(value: 10, child: Text('10')),
                          DropdownMenuItem(value: 20, child: Text('20')),
                        ],
                        onChanged: (v) {
                          if (v != null) state.setPageSize(v);
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: state.prevPage,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      'Page ${state.currentPage}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: state.nextPage,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 TABLE HEADER
  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: const Color(0xFFF0F0F0),
      child: const Row(
        children: [
          Expanded(child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Expense Name', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Payment', style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(width: 90, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  /// 🔹 TABLE ROW
  Widget _tableRow(
      BuildContext context,
      ExpenseState state,
      dynamic e,
      int index,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(e.date)),
          Expanded(child: Text(e.category)),
          Expanded(child: Text(e.expenseName)),
          Expanded(child: Text('₹ ${e.amount}')),
          Expanded(child: Text(e.paymentMethod)),
          SizedBox(
            width: 110,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => AddExpenseDialog(
                        expense: e,
                        index: index,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.delete, color: Colors.red),
                  onPressed: () => state.deleteExpense(index),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 MOBILE CARD VIEW
  Widget _mobileExpenseCard(
      BuildContext context,
      ExpenseState state,
      dynamic e,
      int index,
      ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.expenseName,
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("Date: ${e.date}"),
            Text("Category: ${e.category}"),
            Text("Payment: ${e.paymentMethod}"),
            Text("Amount: ₹ ${e.amount}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => AddExpenseDialog(
                        expense: e,
                        index: index,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.delete, color: Colors.red),
                  onPressed: () => state.deleteExpense(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.year}";
  }
}
