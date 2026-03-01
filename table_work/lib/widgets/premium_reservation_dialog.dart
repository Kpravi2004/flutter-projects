import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../models/waiter_model.dart';

class PremiumReservationDialog extends StatefulWidget {
  final TableModel table;
  final Color accentColor;
  final Color surfaceColor;
  final Function(String, int, String, WaiterModel?) onReserved;

  const PremiumReservationDialog({
    Key? key,
    required this.table,
    required this.accentColor,
    required this.surfaceColor,
    required this.onReserved,
  }) : super(key: key);

  @override
  State<PremiumReservationDialog> createState() => _PremiumReservationDialogState();
}

class _PremiumReservationDialogState extends State<PremiumReservationDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  int _guestCount = 2;
  WaiterModel? _selectedWaiter;

  // Sample waiters for demo
  final List<WaiterModel> _waiters = [
    WaiterModel(id: '1', name: 'James Rodriguez', code: 'W001', rating: 4.9),
    WaiterModel(id: '2', name: 'Emma Watson', code: 'W002', rating: 4.8),
    WaiterModel(id: '3', name: 'Sarah Chen', code: 'W003', rating: 5.0),
  ];

  @override
  void initState() {
    super.initState();
    _guestCount = widget.table.maxGuests ~/ 2;

    // Set default time to current time + 1 hour
    final now = DateTime.now();
    final reservedTime = now.add(const Duration(hours: 1));
    _timeController.text = '${reservedTime.hour.toString().padLeft(2, '0')}:${reservedTime.minute.toString().padLeft(2, '0')}';
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    Icons.event_available,
                    color: widget.accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reserve Table ${widget.table.number}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.table.maxGuests} seats • ${widget.table.floor}',
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

            // Guest Name
            const Text(
              'Guest Name',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter guest name',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                prefixIcon: Icon(Icons.person, color: widget.accentColor),
              ),
            ),

            const SizedBox(height: 16),

            // Guest Count
            const Text(
              'Number of Guests',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _guestCount.toDouble(),
                    min: 1,
                    max: widget.table.maxGuests.toDouble(),
                    divisions: widget.table.maxGuests,
                    activeColor: widget.accentColor,
                    onChanged: (value) {
                      setState(() {
                        _guestCount = value.round();
                      });
                    },
                  ),
                ),
                Container(
                  width: 50,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_guestCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: widget.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Reservation Time
            const Text(
              'Reservation Time',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _timeController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'HH:MM',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                prefixIcon: Icon(Icons.access_time, color: widget.accentColor),
                suffixIcon: IconButton(
                  icon: Icon(Icons.schedule, color: widget.accentColor),
                  onPressed: _selectTime,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Waiter Assignment (Optional)
            const Text(
              'Assign Waiter (Optional)',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<WaiterModel?>(
                  value: _selectedWaiter,
                  isExpanded: true,
                  dropdownColor: widget.surfaceColor,
                  style: const TextStyle(color: Colors.white),
                  hint: const Text(
                    'Select a waiter',
                    style: TextStyle(color: Colors.white54),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('No waiter assigned'),
                    ),
                    ..._waiters.map((waiter) {
                      return DropdownMenuItem(
                        value: waiter,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: widget.accentColor.withOpacity(0.2),
                              child: Text(
                                waiter.name[0],
                                style: TextStyle(color: widget.accentColor),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(waiter.name),
                            const SizedBox(width: 8),
                            Icon(Icons.star, color: Colors.amber, size: 12),
                            Text(' ${waiter.rating}'),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (waiter) {
                    setState(() {
                      _selectedWaiter = waiter;
                    });
                  },
                ),
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
                    onPressed: _nameController.text.isEmpty
                        ? null
                        : () {
                      widget.onReserved(
                        _nameController.text,
                        _guestCount,
                        _timeController.text,
                        _selectedWaiter,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.accentColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Confirm Reservation'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: widget.accentColor,
              onPrimary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }
}