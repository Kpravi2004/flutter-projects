import 'dart:async';
import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../models/waiter_model.dart';
import '../widgets/table_card.dart';
import '../widgets/add_table_dialog.dart';
import '../widgets/seat_config_dialog.dart';
import '../widgets/add_waiter_dialog.dart';
import '../widgets/waiter_selection_dialog.dart';
import '../widgets/bill_split_dialog.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/seat_selection_dialog.dart';
import '../services/api_service.dart';
import '../models/seat_model.dart';
import 'bill_seat_selection_screen.dart';
import 'order_page.dart'; // ADDED
import '../widgets/seat_edit_dialog.dart';
class MobileTableScreen extends StatefulWidget {
  const MobileTableScreen({Key? key}) : super(key: key);

  @override
  State<MobileTableScreen> createState() => _MobileTableScreenState();
}

class _MobileTableScreenState extends State<MobileTableScreen> {
  List<TableModel> tables = [];
  List<WaiterModel> waiters = [];
  List<String> floors = [];
  String selectedFloor = 'All Floors';
  String selectedStatus = 'All';
  int? selectedSize;
  bool isLoading = true;

  DateTime _currentTime = DateTime.now();
  late Timer _timer;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchTables();
    _fetchWaiters();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // -------------------- API CALLS --------------------

  Future<void> _fetchWaiters() async {
    try {
      List<WaiterModel> fetched = await ApiService.fetchWaiters();
      if (mounted) setState(() => waiters = fetched);
    } catch (e) {
      print('Error fetching waiters: $e');
      _showError('Failed to load waiters');
    }
  }

  // -------------------- UI HELPERS --------------------

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getFormattedTime() => '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}';
  String _getFormattedDate() {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${_currentTime.day} ${months[_currentTime.month - 1]}';
  }

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.free:   return AppConstants.successGreen;
      case TableStatus.occupied:return AppConstants.errorRed;
      case TableStatus.reserved:return AppConstants.warningOrange;
      case TableStatus.cleaning:return AppConstants.cleaningBlue;
      case TableStatus.billed:  return AppConstants.billedPurple;
    }
  }

  List<TableModel> get filteredTables {
    return tables.where((table) {
      if (selectedFloor != 'All Floors' && table.floor != selectedFloor) return false;
      if (selectedStatus != 'All') {
        TableStatus status;
        switch (selectedStatus) {
          case 'Free':      status = TableStatus.free; break;
          case 'Occupied':  status = TableStatus.occupied; break;
          case 'Reserved':  status = TableStatus.reserved; break;
          case 'Cleaning':  status = TableStatus.cleaning; break;
          case 'Billed':    status = TableStatus.billed; break;
          default: return true;
        }
        if (table.status != status) return false;
      }
      if (selectedSize != null && table.maxGuests != selectedSize) return false;
      if (_searchQuery.isNotEmpty && !table.number.contains(_searchQuery)) return false;
      return true;
    }).toList();
  }

  // -------------------- BUILD --------------------

  @override
  Widget build(BuildContext context) {
    int total = filteredTables.length;
    int free = filteredTables.where((t) => t.status == TableStatus.free).length;
    int occ = filteredTables.where((t) => t.status == TableStatus.occupied).length;

    return Scaffold(
      backgroundColor: AppConstants.lightBackground,
      appBar: _buildMobileAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildMobileStats(total, free, occ),
            _buildMobileSearch(),
            _buildFilterRow(),
            _buildMobileFloorChips(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppConstants.tealPrimary))
                  : filteredTables.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.table_restaurant, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('No tables found', style: TextStyle(color: AppConstants.textSecondary)),
                  ],
                ),
              )
                  : RefreshIndicator(
                onRefresh: () => _fetchTables(showLoading: true),
                color: AppConstants.tealPrimary,
                backgroundColor: AppConstants.lightSurface,
                child: GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(6),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.95,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: filteredTables.length,
                  itemBuilder: (context, index) {
                    try {
                      final table = filteredTables[index];
                      return TableCard(
                        table: table,
                        onTap: () => _showTableOptions(table),
                        onLongPress: () => _showEditTableDialog(table),
                      );
                    } catch (e, stack) {
                      print('Error building table card at index $index: $e\n$stack');
                      return Container(
                        color: Colors.red,
                        child: Center(child: Text('Error', style: TextStyle(color: Colors.white))),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- UI COMPONENTS --------------------

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: AppConstants.lightSurface,
      elevation: 1,
      toolbarHeight: 56,
      title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('SENTINIX', style: TextStyle(color: AppConstants.tealDark, fontSize: AppConstants.fontSizeLg, fontWeight: FontWeight.bold)),
              Text(_getFormattedDate(), style: TextStyle(color: AppConstants.textSecondary, fontSize: AppConstants.fontSizeXs)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppConstants.lightBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.3), width: AppConstants.borderThin),
            ),
            child: Text(_getFormattedTime(), style: TextStyle(color: AppConstants.tealDark, fontSize: AppConstants.fontSizeSm, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStats(int total, int free, int occ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _buildStatCard(Icons.table_restaurant, '$total', 'Total', [AppConstants.tealLight, AppConstants.tealPrimary]),
          const SizedBox(width: 4),
          _buildStatCard(Icons.check_circle, '$free', 'Free', [AppConstants.successGreen.withOpacity(0.7), AppConstants.successGreen]),
          const SizedBox(width: 4),
          _buildStatCard(Icons.people, '$occ', 'Occ', [AppConstants.errorRed.withOpacity(0.7), AppConstants.errorRed]),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, List<Color> gradientColors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontSize: AppConstants.fontSizeMd, fontWeight: FontWeight.bold)),
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: AppConstants.fontSizeXs)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileSearch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppConstants.lightSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.2), width: AppConstants.borderThin),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: TextStyle(color: AppConstants.textPrimary, fontSize: AppConstants.fontSizeSm),
          decoration: InputDecoration(
            hintText: 'Search tables...',
            hintStyle: TextStyle(color: AppConstants.textHint, fontSize: AppConstants.fontSizeXs),
            prefixIcon: Icon(Icons.search, color: AppConstants.tealPrimary, size: 18),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(child: _buildDropdown(
            value: selectedStatus,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All Status')),
              DropdownMenuItem(value: 'Free', child: Text('Free')),
              DropdownMenuItem(value: 'Occupied', child: Text('Occupied')),
              DropdownMenuItem(value: 'Reserved', child: Text('Reserved')),
              DropdownMenuItem(value: 'Cleaning', child: Text('Cleaning')),
              DropdownMenuItem(value: 'Billed', child: Text('Billed')),
            ],
            onChanged: (v) => setState(() => selectedStatus = v!),
          )),
          const SizedBox(width: 6),
          Expanded(child: _buildDropdown(
            value: selectedSize?.toString() ?? 'All',
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All Sizes')),
              DropdownMenuItem(value: '2', child: Text('2 Seats')),
              DropdownMenuItem(value: '4', child: Text('4 Seats')),
              DropdownMenuItem(value: '6', child: Text('6 Seats')),
              DropdownMenuItem(value: '8', child: Text('8 Seats')),
            ],
            onChanged: (v) {
              setState(() { selectedSize = v == 'All' ? null : int.parse(v!); });
            },
          )),
          const SizedBox(width: 6),
          _buildIconButton(Icons.add, 'Add', AppConstants.tealPrimary, _showAddTableDialog),
          const SizedBox(width: 4),
          _buildIconButton(Icons.person_add, 'Waiter', AppConstants.coralAccent, _showAddWaiterDialog),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<DropdownMenuItem<String>> items, required void Function(String?) onChanged}) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppConstants.lightSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.2), width: AppConstants.borderThin),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppConstants.lightSurface,
          style: TextStyle(color: AppConstants.textPrimary, fontSize: AppConstants.fontSizeSm),
          icon: Icon(Icons.arrow_drop_down, color: AppConstants.tealPrimary, size: 20),
          items: items,
          onChanged: onChanged,
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 48,
        decoration: BoxDecoration(
          color: AppConstants.lightSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: AppConstants.borderThin),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            Text(label, style: TextStyle(color: color, fontSize: AppConstants.fontSizeXs, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileFloorChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFloorChip('All', 'All Floors'),
          ...floors.map((floor) => _buildFloorChip(floor, floor)),
          _buildAddFloorChip(),
        ],
      ),
    );
  }

  Widget _buildFloorChip(String label, String value) {
    bool isSelected = selectedFloor == value;
    return GestureDetector(
      onTap: () => setState(() => selectedFloor = value),
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.tealLight : AppConstants.lightSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppConstants.tealPrimary : AppConstants.tealPrimary.withOpacity(0.2),
            width: AppConstants.borderThin,
          ),
          boxShadow: isSelected ? null : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppConstants.tealDark : AppConstants.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: AppConstants.fontSizeSm,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddFloorChip() {
    return GestureDetector(
      onTap: _showAddFloorDialog,
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppConstants.lightSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.2), width: AppConstants.borderThin),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: AppConstants.tealPrimary, size: 16),
            const SizedBox(width: 4),
            Text('Add', style: TextStyle(color: AppConstants.textPrimary, fontSize: AppConstants.fontSizeSm)),
          ],
        ),
      ),
    );
  }

  // -------------------- DIALOGS --------------------

  void _showTableOptions(TableModel table) {
    int freeSeats = table.maxGuests - table.guests;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppConstants.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getStatusColor(table.status).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.table_restaurant,
                      color: _getStatusColor(table.status),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Table ${table.number}',
                          style: TextStyle(
                            color: AppConstants.textPrimary,
                            fontSize: AppConstants.fontSizeLg,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${table.maxGuests} seats • ${table.floor}',
                          style: TextStyle(
                            color: AppConstants.textSecondary,
                            fontSize: AppConstants.fontSizeSm,
                          ),
                        ),
                        if (table.status == TableStatus.occupied)
                          Text(
                            '${table.guests} occupied, $freeSeats free',
                            style: TextStyle(
                              color: freeSeats > 0 ? AppConstants.successGreen : Colors.grey,
                              fontSize: AppConstants.fontSizeSm,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppConstants.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Actions for FREE table
              if (table.status == TableStatus.free) ...[
                _buildActionTile(
                  Icons.person_add,
                  'Assign Waiter',
                  AppConstants.tealPrimary,
                      () {
                    Navigator.pop(context);
                    _showWaiterSelectionDialog(table);
                  },
                ),
                _buildActionTile(
                  Icons.edit,
                  'Edit Table',
                  AppConstants.tealPrimary,
                      () {
                    Navigator.pop(context);
                    _showEditTableDialog(table);
                  },
                ),
                _buildActionTile(
                  Icons.event_seat,
                  'Edit Seats',
                  AppConstants.coralAccent,
                      () {
                    Navigator.pop(context);
                    _showEditSeatsDialog(table);
                  },
                ),
                _buildActionTile(
                  Icons.delete,
                  'Delete Table',
                  AppConstants.errorRed,
                      () async {
                    Navigator.pop(context);
                    try {
                      await ApiService.deleteTable(table.id);
                      setState(() => tables.remove(table));
                      _showSuccess('Table deleted');
                    } catch (e) {
                      _showError('Failed to delete table');
                    }
                  },
                ),
              ],

              // Actions for OCCUPIED table
              if (table.status == TableStatus.occupied) ...[
                _buildActionTile(
                  Icons.restaurant_menu,
                  'Add Bill',
                  AppConstants.successGreen,
                      () {
                    Navigator.pop(context);
                    _showBillEntryDialog(table);
                  },
                ),
                _buildActionTile(
                  Icons.person,
                  'Change Waiter',
                  AppConstants.tealPrimary,
                      () {
                    Navigator.pop(context);
                    _showWaiterSelectionDialog(table);
                  },
                ),
                if (freeSeats > 0)
                  _buildActionTile(
                    Icons.group_add,
                    'Add Guests',
                    AppConstants.coralAccent,
                        () {
                      Navigator.pop(context);
                      _showAddGuestsDialog(table);
                    },
                  ),
                _buildActionTile(
                  Icons.edit,
                  'Edit Table',
                  AppConstants.tealPrimary,
                      () {
                    Navigator.pop(context);
                    _showEditTableDialog(table);
                  },
                ),
                _buildActionTile(
                  Icons.event_seat,
                  'Edit Seats',
                  AppConstants.coralAccent,
                      () {
                    Navigator.pop(context);
                    _showEditSeatsDialog(table);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 22)),
      title: Text(label, style: TextStyle(color: AppConstants.textPrimary, fontSize: AppConstants.fontSizeMd)),
      trailing: Icon(Icons.arrow_forward_ios, color: color, size: 16),
      onTap: onTap,
    );
  }

  void _showAddFloorDialog() {
    TextEditingController c = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.lightSurface,
        title: const Text('Add Floor', style: TextStyle(color: AppConstants.textPrimary)),
        content: TextField(
          controller: c,
          style: const TextStyle(color: AppConstants.textPrimary),
          decoration: InputDecoration(
            labelText: 'Floor Name',
            labelStyle: TextStyle(color: AppConstants.tealPrimary),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: AppConstants.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.tealPrimary, foregroundColor: Colors.white),
            onPressed: () {
              if (c.text.isNotEmpty) {
                setState(() => floors.add(c.text.trim()));
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchTables({bool showLoading = true}) async {
    if (!mounted) return;
    if (showLoading) setState(() => isLoading = true);
    try {
      print('📡 Fetching tables...');
      List<TableModel> fetchedTables = await ApiService.fetchTables();
      if (!mounted) return;

      print('✅ Fetched ${fetchedTables.length} tables');
      if (fetchedTables.isNotEmpty) {
        print('   First table ID: ${fetchedTables[0].id}, number: ${fetchedTables[0].number}');
      }

      Set<String> uniqueFloors = {};
      for (var table in fetchedTables) {
        if (table.floor.isNotEmpty) uniqueFloors.add(table.floor.trim());
      }
      List<String> floorList = uniqueFloors.toList()..sort();

      setState(() {
        tables = fetchedTables;
        floors = floorList.isEmpty ? ['Main Floor'] : floorList;
        if (selectedFloor != 'All Floors' && !floors.contains(selectedFloor)) {
          selectedFloor = 'All Floors';
        }
        if (showLoading) isLoading = false;
      });

      print('🔄 setState called, tables.length = ${tables.length}');
      print('   filteredTables length = ${filteredTables.length}');
    } catch (e, stack) {
      print('❌ Error fetching tables: $e\n$stack');
      if (!mounted) return;
      if (showLoading) setState(() => isLoading = false);
      _showError('Failed to load tables: $e');
    }
  }

  void _showAddTableDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AddTableDialog(
        floors: floors,
        currentFloor: selectedFloor == 'All Floors' ? floors.first : selectedFloor,
        onTableAdded: (newTable) async {
          Navigator.of(dialogContext).pop(); // close AddTableDialog
          if (!mounted) return;
          setState(() => isLoading = true);
          try {
            TableModel created = await ApiService.createTable(newTable.toJson());
            if (!mounted) return;
            _showSuccess('Table created with ID ${created.id}');

            // Generate default seats for the new table
            List<SeatModel> defaultSeats = List.generate(
              created.maxGuests,
                  (index) => SeatModel(
                id: 0,
                seatNo: index + 1,
                status: 'Free',
                colorCode: 'White',
                tableId: created.id,
                billingStatus: false,
              ),
            );

            // Use the new SeatEditDialog for initial seat configuration
            bool? configured = await showDialog(
              context: context,
              builder: (ctx) => SeatEditDialog(
                seats: defaultSeats,
                tableNumber: int.parse(created.number),
                onSave: (selectedSeats) async {
                  // Save the selected seats via API
                  for (var seat in selectedSeats) {
                    if (seat.id == 0) {
                      await ApiService.createSeat(
                        tableId: created.id,
                        seatNo: seat.seatNo,
                        status: seat.status,
                        colorCode: seat.colorCode,
                      );
                    } else {
                      await ApiService.updateSeat(
                        seatId: seat.id,
                        seatNo: seat.seatNo,
                        status: seat.status,
                        colorCode: seat.colorCode,
                      );
                    }
                    // Also update billing status if changed (for existing seats)
                    if (seat.id != 0) {
                      await ApiService.updateSeatBillingStatus(seat.id, seat.billingStatus);
                    }
                  }
                },
              ),
            );

            if (!mounted) return;

            // Wait a moment for backend to settle, then refresh
            await Future.delayed(const Duration(milliseconds: 500));
            await _fetchTables(showLoading: false);

            if (configured == true) {
              _showSuccess('Seats configured');
            }
          } catch (e) {
            if (!mounted) return;
            _showError('Failed to create table: $e');
            await _fetchTables(showLoading: false);
          } finally {
            if (mounted) {
              setState(() => isLoading = false);
            }
          }
        },
      ),
    );
  }

  void _showAddWaiterDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AddWaiterDialog(
        onWaiterAdded: (newWaiter) async {
          Navigator.of(dialogContext).pop();
          try {
            WaiterModel created = await ApiService.createWaiter(newWaiter.name);
            if (!mounted) return;
            setState(() => waiters.add(created));
            _showSuccess('Waiter ${created.name} added');
          } catch (e) {
            if (!mounted) return;
            _showError('Failed to add waiter: $e');
          }
        },
      ),
    );
  }

  void _showWaiterSelectionDialog(TableModel table) {
    showDialog(
      context: context,
      builder: (context) => WaiterSelectionDialog(
        table: table,
        waiters: waiters,
        onWaiterSelected: (waiter) {
          setState(() {
            table.waiterId = waiter.id;
            table.waiterName = waiter.name;
          });
          Navigator.pop(context);
          _showGuestSelectionDialog(table);
        },
        onAddWaiter: () {
          Navigator.pop(context);
          _showAddWaiterDialog();
        },
      ),
    );
  }

  void _showGuestSelectionDialog(TableModel table) async {
    List<SeatModel>? seats;
    try {
      seats = await ApiService.getSeatsByTable(table.id);
    } catch (e) {
      _showError('Failed to fetch seats');
      return;
    }

    if (seats == null || seats.isEmpty) {
      _showError('No seats found for this table');
      return;
    }

    bool? confirmed = await showDialog(
      context: context,
      builder: (context) => SeatSelectionDialog(
        seats: seats!, // now non-nullable
        maxGuests: table.maxGuests,
        tableNumber: int.parse(table.number),
        onSeatsSelected: (selectedSeats) async {
          int occupiedCount = selectedSeats.where((s) => s.status == 'Occupied').length;
          setState(() {
            table.seats = selectedSeats;
            table.guests = occupiedCount;
            table.status = occupiedCount > 0 ? TableStatus.occupied : TableStatus.free;
          });

          try {
            await ApiService.updateTable(table);
            _showSuccess('Table updated');
          } catch (e) {
            _showError('Failed to update table');
          }
        },
      ),
    );
  }

  void _showBillSplitOption(TableModel table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.lightSurface,
        title: const Text('Split Bill?', style: TextStyle(color: AppConstants.textPrimary)),
        content: Text('Split for multiple families?', style: TextStyle(color: AppConstants.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('No', style: TextStyle(color: AppConstants.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.tealPrimary, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              _showBillSplitDialog(table);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _showBillSplitDialog(TableModel table) {
    showDialog(
      context: context,
      builder: (context) => BillSplitDialog(
        table: table,
        onBillsCreated: (bills) => setState(() => table.bills = bills),
      ),
    );
  }

  // MODIFIED METHOD
  void _showBillEntryDialog(TableModel table) {
    final screenContext = context; // capture the screen's context
    showDialog(
      context: screenContext,
      builder: (dialogContext) => SelectSeatsDialog(
        onConfirm: (seatIds) async {
          Navigator.pop(dialogContext); // close the dialog
          // Now navigate using the screen's context
          final result = await Navigator.push(
            screenContext,
            MaterialPageRoute(
              builder: (context) => OrderPage(
                seatIds: seatIds,
                onBillConfirmed: () async {
                  await _fetchTables();
                  _showSuccess('Bill generated and seats marked as billed');
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddGuestsDialog(TableModel table) {
    int current = table.guests;
    int max = table.maxGuests;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppConstants.lightSurface,
            title: Text('Add Guests', style: TextStyle(color: AppConstants.textPrimary, fontSize: AppConstants.fontSizeLg)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Current: $current  |  Max: $max', style: TextStyle(color: AppConstants.textSecondary, fontSize: AppConstants.fontSizeSm)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: Icon(Icons.remove_circle, color: AppConstants.errorRed, size: 36), onPressed: current > 0 ? () => setState(() => current--) : null),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(border: Border.all(color: AppConstants.tealPrimary), borderRadius: BorderRadius.circular(8)),
                      child: Text('$current', style: TextStyle(color: AppConstants.textPrimary, fontSize: AppConstants.fontSizeXl, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(icon: Icon(Icons.add_circle, color: AppConstants.successGreen, size: 36), onPressed: current < max ? () => setState(() => current++) : null),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: AppConstants.textSecondary))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppConstants.tealPrimary, foregroundColor: Colors.white),
                onPressed: () async {
                  this.setState(() {
                    table.guests = current;
                    table.updateSeatsFromGuestCount();
                  });
                  Navigator.pop(context);
                  try {
                    await ApiService.updateTable(table);
                    if (table.maxGuests >= 6 && current >= 4) _showBillSplitOption(table);
                  } catch (e) {
                    _showError('Failed to update');
                    _fetchTables();
                  }
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _settleBill(TableModel table) async {
    setState(() {
      table.status = TableStatus.free;
      table.amount = 0;
      table.guests = 0;
      table.waiterId = null;
      table.waiterName = null;
      table.bills = null;
      for (var seat in table.seats) seat.status = 'Free';
    });
    try {
      await ApiService.updateTable(table);
      _showSuccess('Table settled');
    } catch (e) {
      _showError('Failed to settle');
      _fetchTables();
    }
  }

  void _showEditTableDialog(TableModel table) {
    // Make local copies of the data we'll edit
    String tempNumber = table.number;
    String tempName = table.name;
    int tempMaxGuests = table.maxGuests;
    String tempFloor = table.floor;
    String tempStatus = table.status == TableStatus.free ? 'Active' : 'Inactive';

    // Mutable copy of seats (we'll add/remove as capacity changes)
    List<SeatModel> tempSeats = table.seats.map((s) => SeatModel(
      id: s.id,
      seatNo: s.seatNo,
      status: s.status,
      colorCode: s.colorCode,
      tableId: s.tableId,
    )).toList()..sort((a,b) => a.seatNo.compareTo(b.seatNo));

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppConstants.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Edit Table', style: TextStyle(color: AppConstants.textPrimary, fontSize: AppConstants.fontSizeXl, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Table Number
                  TextField(
                    controller: TextEditingController(text: tempNumber),
                    onChanged: (v) => tempNumber = v,
                    decoration: InputDecoration(
                      labelText: 'Table Number',
                      labelStyle: TextStyle(color: AppConstants.tealPrimary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppConstants.tealPrimary.withOpacity(0.3), width: AppConstants.borderThin),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppConstants.tealPrimary, width: AppConstants.borderNormal),
                      ),
                    ),
                    style: TextStyle(color: AppConstants.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  // Table Name
                  TextField(
                    controller: TextEditingController(text: tempName),
                    onChanged: (v) => tempName = v,
                    decoration: InputDecoration(
                      labelText: 'Table Name',
                      labelStyle: TextStyle(color: AppConstants.tealPrimary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppConstants.tealPrimary.withOpacity(0.3), width: AppConstants.borderThin),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppConstants.tealPrimary, width: AppConstants.borderNormal),
                      ),
                    ),
                    style: TextStyle(color: AppConstants.textPrimary),
                  ),
                  const SizedBox(height: 16),

                  // Capacity and Status in one row
                  Row(
                    children: [
                      // Capacity
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Capacity', style: TextStyle(color: AppConstants.textSecondary, fontSize: AppConstants.fontSizeSm)),
                            const SizedBox(height: 4),
                            Container(
                              height: 46,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.3), width: AppConstants.borderThin),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline,
                                        color: tempMaxGuests > 1 ? AppConstants.errorRed : Colors.grey),
                                    onPressed: tempMaxGuests > 1 ? () => setState(() {
                                      tempMaxGuests--;
                                      if (tempSeats.length > tempMaxGuests) {
                                        tempSeats.removeLast();
                                      }
                                      if (table.guests > tempMaxGuests) {
                                        table.guests = tempMaxGuests;
                                      }
                                    }) : null,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  Text('$tempMaxGuests',
                                      style: TextStyle(color: AppConstants.textPrimary, fontSize: AppConstants.fontSizeMd, fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: Icon(Icons.add_circle_outline,
                                        color: tempMaxGuests < 20 ? AppConstants.successGreen : Colors.grey),
                                    onPressed: tempMaxGuests < 20 ? () => setState(() {
                                      tempMaxGuests++;
                                      tempSeats.add(SeatModel(
                                        id: 0,
                                        seatNo: tempMaxGuests,
                                        status: 'Free',
                                        colorCode: 'White',
                                        tableId: table.id,
                                      ));
                                    }) : null,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status', style: TextStyle(color: AppConstants.textSecondary, fontSize: AppConstants.fontSizeSm)),
                            const SizedBox(height: 4),
                            Container(
                              height: 46,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.3), width: AppConstants.borderThin),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: tempStatus,
                                  dropdownColor: AppConstants.lightSurface,
                                  isExpanded: true,
                                  style: TextStyle(color: AppConstants.textPrimary, fontSize: AppConstants.fontSizeSm),
                                  icon: Icon(Icons.arrow_drop_down, color: AppConstants.tealPrimary, size: 24),
                                  items: const [
                                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                                    DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                                  ],
                                  onChanged: (v) => setState(() => tempStatus = v!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Floor
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Floor', style: TextStyle(color: AppConstants.textSecondary, fontSize: AppConstants.fontSizeSm)),
                      const SizedBox(height: 4),
                      Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.3), width: AppConstants.borderThin),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: tempFloor,
                            dropdownColor: AppConstants.lightSurface,
                            isExpanded: true,
                            style: TextStyle(color: AppConstants.textPrimary, fontSize: AppConstants.fontSizeSm),
                            icon: Icon(Icons.arrow_drop_down, color: AppConstants.tealPrimary, size: 24),
                            items: floors.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                            onChanged: (v) => setState(() => tempFloor = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
                      Expanded(child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: TextStyle(color: AppConstants.textSecondary, fontSize: AppConstants.fontSizeMd)),
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.tealPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          // Apply changes to the original table
                          table.number = tempNumber;
                          table.name = tempName;
                          table.maxGuests = tempMaxGuests;
                          table.floor = tempFloor;
                          table.status = tempStatus == 'Active' ? TableStatus.free : TableStatus.cleaning;
                          if (table.guests > table.maxGuests) {
                            table.guests = table.maxGuests;
                          }

                          Navigator.pop(context); // close edit dialog

                          try {
                            // 1. Update table basic fields
                            await ApiService.updateTable(table);
                            print('Table basic info updated');

                            // 2. Handle seats: determine which to delete, create, update
                            Set<int> originalSeatIds = table.seats.map((s) => s.id).where((id) => id > 0).toSet();
                            Set<int> newSeatIds = tempSeats.map((s) => s.id).where((id) => id > 0).toSet();

                            // Delete seats no longer present
                            for (int sid in originalSeatIds.difference(newSeatIds)) {
                              await ApiService.deleteSeat(sid);
                              print('Deleted seat $sid');
                            }

                            // Create new seats (id == 0)
                            for (var seat in tempSeats.where((s) => s.id == 0)) {
                              await ApiService.createSeat(
                                tableId: table.id,
                                seatNo: seat.seatNo,
                                status: seat.status,
                                colorCode: seat.colorCode,
                              );
                              print('Created seat ${seat.seatNo}');
                            }

                            // Update existing seats (id > 0)
                            for (var seat in tempSeats.where((s) => s.id > 0)) {
                              await ApiService.updateSeat(
                                seatId: seat.id,
                                seatNo: seat.seatNo,
                                status: seat.status,
                                colorCode: seat.colorCode,
                              );
                            }

                            // Refresh table list
                            await _fetchTables();
                            _showSuccess('Table updated');
                          } catch (e) {
                            print('Error updating table: $e');
                            _showError('Failed to update table');
                            await _fetchTables();
                          }
                        },
                        child: const Text('Save'),
                      )),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showEditSeatsDialog(TableModel table) async {
    List<SeatModel>? fetchedSeats;
    try {
      fetchedSeats = await ApiService.getSeatsByTable(table.id);
    } catch (e) {
      _showError('Failed to fetch seats: $e');
      return;
    }

    if (fetchedSeats == null || fetchedSeats.isEmpty) {
      _showError('No seats found for this table');
      return;
    }

    bool? saved = await showDialog(
      context: context,
      builder: (context) => SeatEditDialog(
        seats: fetchedSeats!,
        tableNumber: int.parse(table.number),
        onSave: (updatedSeats) async {
          try {
            // Update each seat
            for (var seat in updatedSeats) {
              await ApiService.updateSeat(
                seatId: seat.id,
                seatNo: seat.seatNo,
                status: seat.status,
                colorCode: seat.colorCode,
              );
              // Update billing status if changed
              await ApiService.updateSeatBillingStatus(seat.id, seat.billingStatus);
            }

            // Recalculate table status based on occupied seats
            int occCount = updatedSeats.where((s) => s.status == 'Occupied').length;
            table.guests = occCount;
            table.status = occCount > 0 ? TableStatus.occupied : TableStatus.free;

            // Refresh table list
            await _fetchTables();
            _showSuccess('Seats updated');
          } catch (e) {
            _showError('Failed to update seats: $e');
            await _fetchTables();
          }
        },
      ),
    );
  }
}