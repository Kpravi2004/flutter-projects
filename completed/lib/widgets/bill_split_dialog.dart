import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../models/order_model.dart';

class BillSplitDialog extends StatefulWidget {
  final TableModel table;
  final Function(List<BillSplit>) onBillsCreated;

  const BillSplitDialog({
    Key? key,
    required this.table,
    required this.onBillsCreated,
  }) : super(key: key);

  @override
  State<BillSplitDialog> createState() => _BillSplitDialogState();
}

class _BillSplitDialogState extends State<BillSplitDialog> {
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Split Bill', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Table ${widget.table.number} • ${widget.table.guests} Guests', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),

            if (bills.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: bills.length,
                  itemBuilder: (context, index) {
                    final bill = bills[index];
                    return ListTile(
                      leading: CircleAvatar(radius: 16, child: Text('${index + 1}')),
                      title: Text(bill.familyName),
                      subtitle: Text('${bill.guests} guests'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() { remainingGuests += bill.guests; bills.removeAt(index); }),
                      ),
                    );
                  },
                ),
              ),

            if (remainingGuests > 0) _buildAddBillSection(),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Remaining Guests:'),
                  Text('$remainingGuests', style: TextStyle(fontWeight: FontWeight.bold, color: remainingGuests == 0 ? Colors.green : Colors.orange)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: remainingGuests == 0 && bills.isNotEmpty ? () => widget.onBillsCreated(bills) : null,
                  child: const Text('Create Bills'),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddBillSection() {
    final nameController = TextEditingController();
    int selectedGuests = 1;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Family/Group Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Guests:'),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.remove, color: Colors.red), onPressed: selectedGuests > 1 ? () => setState(() => selectedGuests--) : null),
                  Text('$selectedGuests'),
                  IconButton(icon: const Icon(Icons.add, color: Colors.green), onPressed: selectedGuests < remainingGuests ? () => setState(() => selectedGuests++) : null),
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