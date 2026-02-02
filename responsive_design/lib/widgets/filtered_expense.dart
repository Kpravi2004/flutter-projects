import 'package:flutter/material.dart';

class FiltersRow extends StatelessWidget {
  final String selectedCategory;
  final String selectedPayment;
  final Function(String) onCategoryChanged;
  final Function(String) onPaymentChanged;

  const FiltersRow({
    super.key,
    required this.selectedCategory,
    required this.selectedPayment,
    required this.onCategoryChanged,
    required this.onPaymentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // CATEGORY FILTER
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: const InputDecoration(
              labelText: "Category",
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: "All", child: Text("All")),
              DropdownMenuItem(value: "Food", child: Text("Food")),
              DropdownMenuItem(value: "Travel", child: Text("Travel")),
              DropdownMenuItem(value: "Shopping", child: Text("Shopping")),
            ],
            onChanged: (value) {
              if (value != null) {
                onCategoryChanged(value);
              }
            },
          ),
        ),

        const SizedBox(width: 16),

        // PAYMENT FILTER
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<String>(
            value: selectedPayment,
            decoration: const InputDecoration(
              labelText: "Payment",
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: "All", child: Text("All")),
              DropdownMenuItem(value: "Cash", child: Text("Cash")),
              DropdownMenuItem(value: "Card", child: Text("Card")),
              DropdownMenuItem(value: "UPI", child: Text("UPI")),
            ],
            onChanged: (value) {
              if (value != null) {
                onPaymentChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }
}
