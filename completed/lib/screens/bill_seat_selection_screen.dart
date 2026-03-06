import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../models/seat_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class SelectSeatsDialog extends StatefulWidget {
  final Function(List<int> seatIds) onConfirm;

  const SelectSeatsDialog({Key? key, required this.onConfirm}) : super(key: key);

  @override
  State<SelectSeatsDialog> createState() => _SelectSeatsDialogState();
}

class _SelectSeatsDialogState extends State<SelectSeatsDialog> {
  List<TableModel> _tables = [];
  List<SeatModel> _selectedSeats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    try {
      List<TableModel> tables = await ApiService.fetchTables();
      // For each table, fetch its seats
      for (var table in tables) {
        try {
          List<SeatModel> seats = await ApiService.getSeatsByTable(table.id);
          table.seats = seats; // assign fetched seats to the table
        } catch (e) {
          print('Error fetching seats for table ${table.id}: $e');
          // If seats can't be fetched, the table won't show any seats (ignore)
        }
      }
      setState(() {
        _tables = tables.where((table) {
          return table.seats.any((seat) =>
          (seat.status == 'Occupied' || seat.status == 'Reserved') && !seat.billingStatus
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading tables: $e')),
      );
      Navigator.pop(context);
    }
  }

  void _toggleSeat(SeatModel seat) {
    setState(() {
      if (_selectedSeats.contains(seat)) {
        _selectedSeats.remove(seat);
      } else {
        _selectedSeats.add(seat);
      }
    });
  }

  bool _isSeatSelectable(SeatModel seat) {
    return (seat.status == 'Occupied' || seat.status == 'Reserved') && !seat.billingStatus;
  }

  void _confirm() {
    if (_selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one seat')),
      );
      return;
    }
    widget.onConfirm(_selectedSeats.map((s) => s.id).toList());
    // Do NOT pop here – let the caller close the dialog
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppConstants.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppConstants.tealPrimary, AppConstants.tealDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.event_seat, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Select Seats',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _tables.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_seat, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'No eligible seats',
                      style: TextStyle(color: AppConstants.textSecondary, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All occupied/reserved seats are already billed',
                      style: TextStyle(color: AppConstants.textHint, fontSize: 14),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _tables.length,
                itemBuilder: (context, index) {
                  final table = _tables[index];
                  final eligibleSeats = table.seats.where(_isSeatSelectable).toList();
                  if (eligibleSeats.isEmpty) return const SizedBox.shrink();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppConstants.tealLight,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.table_restaurant,
                                  color: AppConstants.tealPrimary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Table ${table.number}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppConstants.tealLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${eligibleSeats.length} seat${eligibleSeats.length != 1 ? 's' : ''}',
                                  style: TextStyle(
                                    color: AppConstants.tealPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: eligibleSeats.map((seat) {
                              final isSelected = _selectedSeats.contains(seat);
                              return GestureDetector(
                                onTap: () => _toggleSeat(seat),
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                      colors: [AppConstants.tealPrimary, AppConstants.tealDark],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                        : null,
                                    color: isSelected ? null : Colors.grey.shade50,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppConstants.tealPrimary
                                          : seat.status == 'Occupied'
                                          ? AppConstants.successGreen
                                          : AppConstants.warningOrange,
                                      width: isSelected ? 2 : 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                      BoxShadow(
                                        color: AppConstants.tealPrimary.withOpacity(0.3),
                                        blurRadius: 8,
                                      )
                                    ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${seat.seatNo}',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : seat.status == 'Occupied'
                                            ? AppConstants.successGreen
                                            : AppConstants.warningOrange,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected Seats',
                                style: TextStyle(color: AppConstants.textSecondary, fontSize: 12),
                              ),
                              Text(
                                '${_selectedSeats.length} seat${_selectedSeats.length != 1 ? 's' : ''}',
                                style: TextStyle(
                                  color: AppConstants.tealPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedSeats.isNotEmpty)
                          TextButton(
                            onPressed: () => setState(() => _selectedSeats.clear()),
                            style: TextButton.styleFrom(
                              foregroundColor: AppConstants.errorRed,
                            ),
                            child: const Text('Clear All'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _confirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.tealPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Add Products',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
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
}