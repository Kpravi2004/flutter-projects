import 'package:flutter/material.dart';
import '../models/table_model.dart';

class BillSplitDialog extends StatefulWidget {
  final TableModel table;
  final Function(List<BillSplit>) onBillsCreated;

  const BillSplitDialog({
    Key? key,
    required this.table,
    required this.onBillsCreated,
  }) : super(key: key);

  @override
  _BillSplitDialogState createState() => _BillSplitDialogState();
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
        width: 300,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Split Bill',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Table ${widget.table.number} • ${widget.table.guests} Guests',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),

            if (bills.isNotEmpty)
              Container(
                constraints: BoxConstraints(maxHeight: 150),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: bills.length,
                  itemBuilder: (context, index) {
                    final bill = bills[index];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 12,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(bill.familyName),
                      subtitle: Text('${bill.guests} guests'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red, size: 18),
                        onPressed: () {
                          setState(() {
                            remainingGuests += bill.guests;
                            bills.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

            if (remainingGuests > 0)
              _buildAddBillSection(),

            SizedBox(height: 16),

            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Remaining Guests:'),
                  Text(
                    '$remainingGuests',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: remainingGuests == 0 ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: remainingGuests == 0 && bills.isNotEmpty
                        ? () => widget.onBillsCreated(bills)
                        : null,
                    child: Text('Create Bills'),
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
    final nameController = TextEditingController();
    int selectedGuests = 1;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: EdgeInsets.only(top: 8),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Family/Group Name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text('Guests:'),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.remove, color: Colors.red),
                    onPressed: selectedGuests > 1
                        ? () => setState(() => selectedGuests--)
                        : null,
                  ),
                  Text('$selectedGuests'),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.green),
                    onPressed: selectedGuests < remainingGuests
                        ? () => setState(() => selectedGuests++)
                        : null,
                  ),
                  Spacer(),
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
                    child: Text('Add'),
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