import 'package:flutter/material.dart';
import '../models/table_model.dart'; // Remove order_model.dart import

class PremiumBillSplitDialog extends StatefulWidget {
  final TableModel table;
  final Color accentColor;
  final Color surfaceColor;
  final Function(List<BillSplit>) onBillsCreated;

  const PremiumBillSplitDialog({
    Key? key,
    required this.table,
    required this.accentColor,
    required this.surfaceColor,
    required this.onBillsCreated,
  }) : super(key: key);

  @override
  State<PremiumBillSplitDialog> createState() => _PremiumBillSplitDialogState();
}

class _PremiumBillSplitDialogState extends State<PremiumBillSplitDialog> {
  List<BillSplit> bills = [];
  int remainingGuests = 0;

  @override
  void initState() {
    super.initState();
    remainingGuests = widget.table.guests;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: widget.accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Split Bill',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Table ${widget.table.number} • ${widget.table.guests} Guests',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Bills List
            if (bills.isNotEmpty) ...[
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: bills.length,
                  itemBuilder: (context, index) {
                    final bill = bills[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: widget.accentColor.withOpacity(0.2),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(color: widget.accentColor),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bill.familyName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${bill.guests} guests',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                remainingGuests += bill.guests;
                                bills.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Add Bill Section
            if (remainingGuests > 0)
              _buildAddBillSection(),

            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Remaining Guests:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    '$remainingGuests',
                    style: TextStyle(
                      color: remainingGuests == 0 ? Colors.green : widget.accentColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: remainingGuests == 0 && bills.isNotEmpty
                        ? () => widget.onBillsCreated(bills)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.accentColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Create Bills'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddBillSection() {
    final TextEditingController nameController = TextEditingController();
    int selectedGuests = 1;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Family/Group Name',
                  labelStyle: TextStyle(color: widget.accentColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: widget.accentColor.withOpacity(0.3)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'Guests:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: selectedGuests > 1
                        ? () => setState(() => selectedGuests--)
                        : null,
                  ),
                  Container(
                    width: 40,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$selectedGuests',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.green),
                    onPressed: selectedGuests < remainingGuests
                        ? () => setState(() => selectedGuests++)
                        : null,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: nameController.text.isNotEmpty
                        ? () {
                      this.setState(() {
                        bills.add(BillSplit(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          familyName: nameController.text,
                          guests: selectedGuests,
                          amount: 0,
                          items: [],
                        ));
                        remainingGuests -= selectedGuests;
                      });
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.accentColor,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}