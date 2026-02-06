import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'expense_state.dart';
import 'add_expense_page.dart';

class ExpenseListPage extends StatelessWidget {
  const ExpenseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExpenseState>();
    final expenses = state.paginatedExpenses;

    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
              onPressed: () {
                showGeneralDialog(
                  context: context,
                  barrierDismissible: false,
                  barrierLabel: '',
                  transitionDuration: const Duration(milliseconds: 400),
                  pageBuilder: (_, __, ___) => const SizedBox(),
                  transitionBuilder: (_, anim, __, ___) {
                    return Transform.translate(
                      offset: Offset(0, 120 * (1 - anim.value)),
                      child: Opacity(
                        opacity: anim.value.clamp(0.0, 1.0),
                        child: const AddExpenseDialog(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      /// PAGE LOAD ANIMATION
      body: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (_, value, child) {
          return Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _filters(context, state, isMobile),
              const SizedBox(height: 16),
              Expanded(
                child: isMobile
                    ? _mobileList(context, state, expenses)
                    : _desktopTable(context, state, expenses),
              ),
              const SizedBox(height: 12),
              _pagination(state),
            ],
          ),
        ),
      ),
    );
  }

  // ================= FILTERS =================

  Widget _filters(BuildContext context, ExpenseState state, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _fromDate(context, state),
          const SizedBox(height: 8),
          _toDate(context, state),
          const SizedBox(height: 8),
          _category(state),
          const SizedBox(height: 8),
          _payment(state),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _fromDate(context, state)),
        const SizedBox(width: 12),
        Expanded(child: _toDate(context, state)),
        const SizedBox(width: 12),
        Expanded(child: _category(state)),
        const SizedBox(width: 12),
        Expanded(child: _payment(state)),
      ],
    );
  }

  Widget _fromDate(BuildContext context, ExpenseState state) {
    return TextField(
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'From Date',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.date_range),
      ),
      controller: TextEditingController(
        text: state.fromDate == null ? '' : _formatDate(state.fromDate!),
      ),
      onTap: () => _pickDate(context, state, true),
    );
  }

  Widget _toDate(BuildContext context, ExpenseState state) {
    return TextField(
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'To Date',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.date_range),
      ),
      controller: TextEditingController(
        text: state.toDate == null ? '' : _formatDate(state.toDate!),
      ),
      onTap:
      state.fromDate == null ? null : () => _pickDate(context, state, false),
    );
  }

  Widget _category(ExpenseState state) {
    return DropdownButtonFormField<String>(
      value: state.selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: ['All', 'Food', 'Travel', 'Bills']
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => state.changeCategory(v!),
    );
  }

  Widget _payment(ExpenseState state) {
    return DropdownButtonFormField<String>(
      value: state.selectedPayment,
      decoration: const InputDecoration(
        labelText: 'Payment',
        border: OutlineInputBorder(),
      ),
      items: ['All', 'Cash', 'GPay', 'Paytm']
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => state.changePayment(v!),
    );
  }

  // ================= DATA VIEW =================

  Widget _desktopTable(
      BuildContext context, ExpenseState state, List expenses) {
    return Card(
      child: Column(
        children: [
          _tableHeader(),
          const Divider(height: 1),
          Expanded(
            child: expenses.isEmpty
                ? const Center(child: Text('No expenses found'))
                : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (_, i) =>
                  _animatedTableRow(context, state, expenses[i], i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileList(
      BuildContext context, ExpenseState state, List expenses) {
    return expenses.isEmpty
        ? const Center(child: Text('No expenses found'))
        : ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (_, i) =>
          _animatedMobileCard(context, state, expenses[i], i),
    );
  }

  // ================= ANIMATIONS =================

  Widget _animatedTableRow(
      BuildContext context, ExpenseState state, e, int i) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (i * 60)),
      curve: Curves.easeOutBack,
      builder: (_, value, child) {
        return Transform.translate(
          offset: Offset(40 * (1 - value), 0),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: _tableRow(context, state, e, i),
    );
  }

  Widget _animatedMobileCard(
      BuildContext context, ExpenseState state, dynamic e, int i) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (i * 80)),
      curve: Curves.easeOutBack,
      builder: (_, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: _mobileCard(context, state, e, i),
    );
  }
  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade200,
      child: const Row(
        children: [
          Expanded(child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Payment', style: TextStyle(fontWeight: FontWeight.bold))),
          SizedBox(
            width: 110,
            child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _tableRow(BuildContext context, ExpenseState state, e, int i) {
    return Container(
      padding: const EdgeInsets.all(12),
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
                      builder: (_) =>
                          AddExpenseDialog(expense: e, index: i),
                    );
                  },
                ),
                IconButton(
                  icon:
                  const Icon(CupertinoIcons.delete, color: Colors.red),
                  onPressed: () => state.deleteExpense(i),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileCard(
      BuildContext context,
      ExpenseState state,
      dynamic e,
      int i,
      ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            /// ROW 1 — LABELS
            Row(
              children: [
                Expanded(child: _label('Expense name')),
                _rightLabel('Date'),
              ],
            ),
            const SizedBox(height: 4),

            /// ROW 2 — VALUES
            Row(
              children: [
                Expanded(child: _value(e.expenseName)),
                _rightValue(e.date),
              ],
            ),

            const SizedBox(height: 10),

            /// ROW 3 — LABELS
            Row(
              children: [
                Expanded(child: _label('Category')),
                _rightLabel('Payment'),
              ],
            ),
            const SizedBox(height: 4),

            /// ROW 4 — VALUES
            Row(
              children: [
                Expanded(child: _value(e.category)),
                _rightValue(e.paymentMethod),
              ],
            ),

            const SizedBox(height: 10),

            /// ROW 5 — AMOUNT + ACTIONS
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Amount'),
                      const SizedBox(height: 4),
                      _value('₹ ${e.amount}', bold: true),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              AddExpenseDialog(expense: e, index: i),
                        );
                      },
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red,
                      ),
                      onPressed: () => state.deleteExpense(i),
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

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _value(String text, {bool bold = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: bold ? FontWeight.bold : FontWeight.w600,
      ),
    );
  }

  /// Right column label with fixed width
  Widget _rightLabel(String text) {
    return SizedBox(
      width: 90,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  /// Right column value with fixed width
  Widget _rightValue(String text) {
    return SizedBox(
      width: 90,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }





  Widget _mobileField({
    required String label,
    required String value,
    bool alignRight = false,
    bool bold = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
      alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          softWrap: true,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }





  Widget _mobileInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= PAGINATION =================

  Widget _pagination(ExpenseState state) {
    return Column(
      children: [
        /// ROWS PER PAGE
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Rows per page'),
            const SizedBox(width: 8),
            SizedBox(
              width: 90,
              child: DropdownButtonFormField<int>(
                value: state.pageSize,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 5, child: Text('5')),
                  DropdownMenuItem(value: 10, child: Text('10')),
                  DropdownMenuItem(value: 20, child: Text('20')),
                ],
                onChanged: (v) => state.setPageSize(v!),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        /// PAGINATION
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }


  // ================= HELPERS =================

  Future<void> _pickDate(
      BuildContext context,
      ExpenseState state,
      bool isFrom,
      ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? DateTime.now()
          : (state.fromDate ?? DateTime.now()),
      firstDate: isFrom
          ? DateTime(2020)
          : (state.fromDate ?? DateTime(2020)), // 🔥 constraint
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      if (isFrom) {
        state.setFromDate(picked);

        // 🔥 Reset TO date if invalid
        if (state.toDate != null && state.toDate!.isBefore(picked)) {
          state.setToDate(null);
        }
      } else {
        state.setToDate(picked);
      }
    }
  }


  String _formatDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}-"
          "${d.month.toString().padLeft(2, '0')}-"
          "${d.year}";
}