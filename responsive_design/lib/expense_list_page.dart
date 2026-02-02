import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'expense_state.dart';
import 'add_expense_page.dart';

class ExpenseListPage extends StatelessWidget {
  const ExpenseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ExpenseState>(context);
    final expenses = state.filteredExpenses;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Expenses'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddExpensePage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔹 FILTER BAR (WIDTH REDUCED ONLY)
            Row(
              children: [
                SizedBox(
                  width: 240, // 🔥 controlled width
                  child: DropdownButtonFormField<String>(
                    value: state.selectedCategory,
                    isDense: true,
                    decoration: const InputDecoration(
                      labelText: 'All Categories',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 14),
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
                  width: 240, // 🔥 controlled width
                  child: DropdownButtonFormField<String>(
                    value: state.selectedPayment,
                    isDense: true,
                    decoration: const InputDecoration(
                      labelText: 'All Payments',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 14),
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

            /// 🔹 TABLE
            Expanded(
              child: Card(
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 TABLE HEADER
  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
      color: const Color(0xFFF0F0F0),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              'Expense Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              'Amount',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              'Payment',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              'Actions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
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
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 16,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(e.category)),
          Expanded(child: Text(e.expenseName)),
          Expanded(child: Text('₹ ${e.amount}')),
          Expanded(child: Text(e.paymentMethod)),
          SizedBox(
            width: 90,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddExpensePage(
                          expense: e,
                          index: index,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    size: 18,
                    color: Colors.red,
                  ),
                  onPressed: () => state.deleteExpense(index),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
