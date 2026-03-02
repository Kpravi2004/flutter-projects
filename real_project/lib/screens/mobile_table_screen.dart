import 'dart:async';
import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../models/waiter_model.dart';
import '../widgets/table_card.dart';
import '../widgets/add_table_dialog.dart';
import '../widgets/add_waiter_dialog.dart';
import '../widgets/waiter_selection_dialog.dart';
import '../widgets/bill_split_dialog.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class MobileTableScreen extends StatefulWidget {
  const MobileTableScreen({Key? key}) : super(key: key);

  @override
  State<MobileTableScreen> createState() => _MobileTableScreenState();
}

class _MobileTableScreenState extends State<MobileTableScreen> {
  List<TableModel> tables = [];
  List<WaiterModel> waiters = [];
  List<String> floors = ['Main Floor'];
  String selectedFloor = 'Main Floor';
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
    _loadSampleData();

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

  void _loadSampleData() {
    tables = [
      TableModel(id: '1',
          number: '101',
          status: TableStatus.free,
          guests: 0,
          maxGuests: 4,
          amount: 0,
          floor: 'Main Floor'),
      TableModel(id: '2',
          number: '102',
          status: TableStatus.free,
          guests: 0,
          maxGuests: 4,
          amount: 0,
          floor: 'Main Floor'),
      TableModel(id: '3',
          number: '103',
          status: TableStatus.free,
          guests: 0,
          maxGuests: 4,
          amount: 0,
          floor: 'Main Floor'),
      TableModel(id: '4',
          number: '104',
          status: TableStatus.free,
          guests: 0,
          maxGuests: 4,
          amount: 0,
          floor: 'Main Floor'),
      TableModel(id: '5',
          number: '105',
          status: TableStatus.free,
          guests: 0,
          maxGuests: 6,
          amount: 0,
          floor: 'Main Floor'),
      TableModel(id: '6',
          number: '106',
          status: TableStatus.free,
          guests: 0,
          maxGuests: 6,
          amount: 0,
          floor: 'Main Floor'),
      TableModel(id: '7',
          number: '107',
          status: TableStatus.free,
          guests: 0,
          maxGuests: 8,
          amount: 0,
          floor: 'Main Floor'),
      TableModel(id: '8',
          number: '108',
          status: TableStatus.free,
          guests: 0,
          maxGuests: 8,
          amount: 0,
          floor: 'Main Floor'),
      TableModel(id: '9',
          number: '109',
          status: TableStatus.free,
          guests: 0,
          maxGuests: 4,
          amount: 0,
          floor: 'Main Floor'),
      TableModel(id: '10',
          number: '110',
          status: TableStatus.free,
          guests: 0,
          maxGuests: 6,
          amount: 0,
          floor: 'Main Floor'),
    ];

    waiters = [
      WaiterModel(id: '1', name: 'John', code: 'W001'),
      WaiterModel(id: '2', name: 'Jane', code: 'W002'),
      WaiterModel(id: '3', name: 'Mike', code: 'W003'),
    ];

    setState(() => isLoading = false);
  }

  List<TableModel> get filteredTables {
    return tables.where((table) {
      if (selectedFloor != 'All Floors' && table.floor != selectedFloor)
        return false;

      if (selectedStatus != 'All') {
        TableStatus status;
        switch (selectedStatus) {
          case 'Free':
            status = TableStatus.free;
            break;
          case 'Occupied':
            status = TableStatus.occupied;
            break;
          case 'Reserved':
            status = TableStatus.reserved;
            break;
          case 'Cleaning':
            status = TableStatus.cleaning;
            break;
          case 'Billed':
            status = TableStatus.billed;
            break;
          default:
            return true;
        }
        if (table.status != status) return false;
      }

      if (selectedSize != null && table.maxGuests != selectedSize) return false;
      if (_searchQuery.isNotEmpty && !table.number.contains(_searchQuery))
        return false;

      return true;
    }).toList();
  }

  String _getFormattedTime() {
    return '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime
        .minute.toString().padLeft(2, '0')}';
  }

  String _getFormattedDate() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${_currentTime.day} ${months[_currentTime.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    int totalTables = filteredTables.length;
    int freeTables = filteredTables
        .where((t) => t.status == TableStatus.free)
        .length;
    int occupiedTables = filteredTables
        .where((t) => t.status == TableStatus.occupied)
        .length;

    return Scaffold(
      backgroundColor: AppConstants.darkBackground,
      appBar: _buildMobileAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildMobileStats(totalTables, freeTables, occupiedTables),
            _buildMobileSearch(),
            _buildFilterRow(),
            _buildMobileFloorChips(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                onRefresh: () async => setState(() {}),
                color: AppConstants.goldAccent,
                backgroundColor: AppConstants.darkSurface,
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
                    final table = filteredTables[index];
                    return TableCard(
                      table: table,
                      onTap: () => _showMobileTableOptions(table),
                      onLongPress: () => _showEditTableDialog(table),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: AppConstants.darkSurface,
      elevation: 0,
      toolbarHeight: 56,
      title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    LinearGradient(
                      colors: [AppConstants.goldAccent, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                child: const Text(
                  'SENTINIX',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                _getFormattedDate(),
                style: TextStyle(
                    color: AppConstants.textSecondary, fontSize: 10),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: AppConstants.headerGradient,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppConstants.goldAccent.withOpacity(0.3), width: 1),
            ),
            child: Text(
              _getFormattedTime(),
              style: TextStyle(color: AppConstants.goldAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStats(int total, int free, int occupied) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants.darkElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppConstants.royalPurple.withOpacity(0.3), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                      Icons.table_restaurant, color: Colors.blue, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$total',
                    style: TextStyle(color: AppConstants.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Total',
                    style: TextStyle(
                        color: AppConstants.textSecondary, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants.darkElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppConstants.successGreen.withOpacity(0.3),
                    width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                      Icons.check_circle, color: AppConstants.successGreen,
                      size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$free',
                    style: TextStyle(color: AppConstants.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Free',
                    style: TextStyle(
                        color: AppConstants.textSecondary, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants.darkElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppConstants.errorRed.withOpacity(0.3), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                      Icons.people, color: AppConstants.errorRed, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$occupied',
                    style: TextStyle(color: AppConstants.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Occ',
                    style: TextStyle(
                        color: AppConstants.textSecondary, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSearch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: AppConstants.darkElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: AppConstants.goldAccent.withOpacity(0.3), width: 1),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: TextStyle(color: AppConstants.textPrimary, fontSize: 12),
          decoration: InputDecoration(
            hintText: 'Search tables...',
            hintStyle: TextStyle(color: AppConstants.textHint, fontSize: 11),
            prefixIcon: Icon(
                Icons.search, color: AppConstants.goldAccent, size: 16),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
          Expanded(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppConstants.darkElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppConstants.goldAccent.withOpacity(0.3), width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedStatus,
                  dropdownColor: AppConstants.darkSurface,
                  style: TextStyle(
                      color: AppConstants.textPrimary, fontSize: 12),
                  icon: Icon(
                      Icons.arrow_drop_down, color: AppConstants.goldAccent,
                      size: 18),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Status')),
                    DropdownMenuItem(value: 'Free', child: Text('Free')),
                    DropdownMenuItem(
                        value: 'Occupied', child: Text('Occupied')),
                    DropdownMenuItem(
                        value: 'Reserved', child: Text('Reserved')),
                    DropdownMenuItem(
                        value: 'Cleaning', child: Text('Cleaning')),
                    DropdownMenuItem(value: 'Billed', child: Text('Billed')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => selectedStatus = value);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppConstants.darkElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppConstants.goldAccent.withOpacity(0.3), width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedSize?.toString() ?? 'All',
                  dropdownColor: AppConstants.darkSurface,
                  style: TextStyle(
                      color: AppConstants.textPrimary, fontSize: 12),
                  icon: Icon(
                      Icons.arrow_drop_down, color: AppConstants.goldAccent,
                      size: 18),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Sizes')),
                    DropdownMenuItem(value: '2', child: Text('2 Seats')),
                    DropdownMenuItem(value: '4', child: Text('4 Seats')),
                    DropdownMenuItem(value: '6', child: Text('6 Seats')),
                    DropdownMenuItem(value: '8', child: Text('8 Seats')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedSize = value == 'All' ? null : int.parse(value!);
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          _buildIconButton(Icons.add, 'Add', Colors.green, _showAddTableDialog),
          const SizedBox(width: 4),
          _buildIconButton(Icons.person_add, 'Waiter', AppConstants.goldAccent,
              _showAddWaiterDialog),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, Color color,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            Text(
              label,
              style: TextStyle(
                  color: color, fontSize: 7, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileFloorChips() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildMobileFloorChip('All', 'All Floors'),
          ...floors.map((floor) => _buildMobileFloorChip(floor, floor)),
          _buildMobileAddFloorChip(),
        ],
      ),
    );
  }

  Widget _buildMobileFloorChip(String label, String value) {
    bool isSelected = selectedFloor == value;
    return GestureDetector(
      onTap: () => setState(() => selectedFloor = value),
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.goldAccent : AppConstants
              .darkElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppConstants.goldAccent : AppConstants
                .goldAccent.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : AppConstants.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileAddFloorChip() {
    return GestureDetector(
      onTap: _showAddFloorDialog,
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppConstants.darkElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppConstants.goldAccent.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: AppConstants.goldAccent, size: 12),
            const SizedBox(width: 2),
            Text('Add', style: TextStyle(
                color: AppConstants.textPrimary, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _showMobileTableOptions(TableModel table) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppConstants.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(table.status).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.table_restaurant,
                      color: _getStatusColor(table.status),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Table ${table.number}',
                        style: TextStyle(color: AppConstants.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${table.maxGuests} seats',
                        style: TextStyle(
                            color: AppConstants.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (table.status == TableStatus.free) ...[
                _buildMobileActionTile(
                    Icons.person, 'Assign Waiter', Colors.blue, () {
                  Navigator.pop(context);
                  _showWaiterSelectionDialog(table);
                }),
              ] else ...[
                _buildMobileActionTile(Icons.restaurant_menu, 'Add Bill',
                    AppConstants.successGreen, () {
                      Navigator.pop(context);
                      _showBillEntryDialog(table);
                    }),
                _buildMobileActionTile(Icons.person, 'Change Waiter',
                    AppConstants.goldAccent, () {
                      Navigator.pop(context);
                      _showWaiterSelectionDialog(table);
                    }),
                _buildMobileActionTile(Icons.group_add, 'Add Guests',
                    Colors.teal, () {                 // NEW ACTION
                      Navigator.pop(context);
                      _showAddGuestsDialog(table);
                    }),
                _buildMobileActionTile(Icons.receipt, 'Split Bill',
                    AppConstants.royalPurple, () {
                      Navigator.pop(context);
                      _showBillSplitDialog(table);
                    }),
                _buildMobileActionTile(
                    Icons.payment, 'Settle', AppConstants.errorRed, () {
                  _settleBill(table);
                  Navigator.pop(context);
                }),
              ],
              _buildMobileActionTile(
                  Icons.edit, 'Edit Table', AppConstants.textSecondary, () {
                Navigator.pop(context);
                _showEditTableDialog(table);
              }),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: TextStyle(
                    color: AppConstants.textSecondary, fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileActionTile(IconData icon, String label, Color color,
      VoidCallback onTap) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 16),
      ),
      title: Text(
        label,
        style: TextStyle(color: AppConstants.textPrimary, fontSize: 12),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: color, size: 12),
      onTap: onTap,
    );
  }

  // NEW METHOD: Add Guests Dialog
  void _showAddGuestsDialog(TableModel table) {
    int currentGuests = table.guests;
    int maxGuests = table.maxGuests;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppConstants.darkSurface,
            title: Text('Add Guests to Table ${table.number}',
                style: const TextStyle(color: Colors.white, fontSize: 14)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Current: $currentGuests  |  Max: $maxGuests',
                    style: TextStyle(color: AppConstants.textSecondary, fontSize: 12)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red, size: 32),
                      onPressed: currentGuests > 0
                          ? () => setState(() => currentGuests--)
                          : null,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppConstants.goldAccent),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$currentGuests',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.green, size: 32),
                      onPressed: currentGuests < maxGuests
                          ? () => setState(() => currentGuests++)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: AppConstants.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.goldAccent,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  this.setState(() {
                    table.guests = currentGuests;
                  });
                  Navigator.pop(context);
                  // Optionally suggest bill split if large table
                  if (table.maxGuests >= 6 && currentGuests >= 4) {
                    _showBillSplitOption(table);
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

  void _settleBill(TableModel table) {
    setState(() {
      table.status = TableStatus.free;   // CHANGED: from billed to free
      table.amount = 0;
      table.guests = 0;
      table.waiterId = null;
      table.waiterName = null;
      table.bills = null;
    });
  }

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.free:
        return AppConstants.successGreen;
      case TableStatus.occupied:
        return AppConstants.errorRed;
      case TableStatus.reserved:
        return AppConstants.warningOrange;
      case TableStatus.cleaning:
        return AppConstants.cleaningBlue;
      case TableStatus.billed:
        return AppConstants.billedPurple;
    }
  }

  void _showAddFloorDialog() {
    TextEditingController floorController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            backgroundColor: AppConstants.darkSurface,
            title: const Text('Add Floor',
                style: TextStyle(color: Colors.white, fontSize: 14)),
            content: TextField(
              controller: floorController,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                labelText: 'Floor Name',
                labelStyle: TextStyle(
                    color: AppConstants.goldAccent, fontSize: 11),
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(
                    color: AppConstants.textSecondary, fontSize: 11)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.goldAccent,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  if (floorController.text.isNotEmpty) {
                    setState(() => floors.add(floorController.text));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
    );
  }

  void _showAddTableDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AddTableDialog(
            floors: floors,
            currentFloor: selectedFloor == 'All Floors'
                ? floors.first
                : selectedFloor,
            onTableAdded: (newTable) => setState(() => tables.add(newTable)),
          ),
    );
  }

  void _showAddWaiterDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AddWaiterDialog(
            onWaiterAdded: (newWaiter) =>
                setState(() => waiters.add(newWaiter)),
          ),
    );
  }

  void _showWaiterSelectionDialog(TableModel table) {
    showDialog(
      context: context,
      builder: (context) =>
          WaiterSelectionDialog(
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

  void _showGuestSelectionDialog(TableModel table) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            backgroundColor: AppConstants.darkSurface,
            title: Text('Guests', style: TextStyle(
                color: AppConstants.textPrimary, fontSize: 14)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Max: ${table.maxGuests}', style: TextStyle(
                    color: AppConstants.textSecondary, fontSize: 11)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: List.generate(table.maxGuests, (index) {
                    int count = index + 1;
                    return ChoiceChip(
                      label: Text(
                          '$count', style: const TextStyle(fontSize: 11)),
                      selected: table.guests == count,
                      onSelected: (selected) {
                        setState(() {
                          table.guests = count;
                          table.status = TableStatus.occupied;
                        });
                        Navigator.pop(context);
                        if (table.maxGuests >= 6 && count >= 4) {
                          _showBillSplitOption(table);
                        }
                      },
                      selectedColor: AppConstants.successGreen,
                      backgroundColor: AppConstants.darkElevated,
                      labelStyle: TextStyle(color: AppConstants.textPrimary),
                    );
                  }),
                ),
              ],
            ),
          ),
    );
  }

  void _showBillSplitOption(TableModel table) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            backgroundColor: AppConstants.darkSurface,
            title: const Text('Split Bill?',
                style: TextStyle(color: Colors.white, fontSize: 14)),
            content: Text('Split for multiple families?', style: TextStyle(
                color: AppConstants.textSecondary, fontSize: 11)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('No', style: TextStyle(
                    color: AppConstants.textSecondary, fontSize: 11)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.goldAccent,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _showBillSplitDialog(table);
                },
                child: const Text('Yes', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
    );
  }

  void _showBillSplitDialog(TableModel table) {
    showDialog(
      context: context,
      builder: (context) =>
          BillSplitDialog(
            table: table,
            onBillsCreated: (bills) => setState(() => table.bills = bills),
          ),
    );
  }

  void _showBillEntryDialog(TableModel table) {
    TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            backgroundColor: AppConstants.darkSurface,
            title: const Text('Add Bill',
                style: TextStyle(color: Colors.white, fontSize: 14)),
            content: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(
                    color: AppConstants.goldAccent, fontSize: 11),
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(
                    color: AppConstants.textSecondary, fontSize: 11)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.goldAccent,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  if (amountController.text.isNotEmpty) {
                    setState(() =>
                    table.amount = double.parse(amountController.text));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
    );
  }

  void _showEditTableDialog(TableModel table) {
    int tempMaxGuests = table.maxGuests; // local variable for capacity

    showDialog(
      context: context,
      builder: (context) =>
          StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: AppConstants.darkSurface,
                title: Text('Edit Table ${table.number}',
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Seating Capacity
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: const Text('Seating Capacity',
                          style: TextStyle(color: Colors.white, fontSize: 11)),
                      subtitle: Text('$tempMaxGuests seats',
                          style: TextStyle(
                              color: AppConstants.textSecondary, fontSize: 10)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline,
                                color: tempMaxGuests > 2 ? Colors.red : Colors
                                    .grey),
                            onPressed: tempMaxGuests > 2
                                ? () {
                              setState(() => tempMaxGuests -= 2);
                              // if current guests exceed new capacity, adjust
                              if (table.guests > tempMaxGuests) {
                                table.guests = tempMaxGuests;
                              }
                            }
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppConstants.goldAccent.withOpacity(
                                      0.3)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$tempMaxGuests',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline,
                                color: tempMaxGuests < 8 ? Colors.green : Colors
                                    .grey),
                            onPressed: tempMaxGuests < 8
                                ? () => setState(() => tempMaxGuests += 2)
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: AppConstants.textSecondary),

                    // Status
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: const Text('Status',
                          style: TextStyle(color: Colors.white, fontSize: 11)),
                      subtitle: Text(table.status
                          .toString()
                          .split('.')
                          .last,
                          style: TextStyle(
                              color: AppConstants.textSecondary, fontSize: 10)),
                      trailing: PopupMenuButton<TableStatus>(
                        icon: Icon(Icons.edit, color: AppConstants.goldAccent,
                            size: 16),
                        onSelected: (status) {
                          setState(() => table.status = status);
                          Navigator.pop(context);
                        },
                        itemBuilder: (context) =>
                            TableStatus.values.map((status) {
                              return PopupMenuItem(
                                value: status,
                                child: Text(status
                                    .toString()
                                    .split('.')
                                    .last,
                                    style: const TextStyle(fontSize: 11)),
                              );
                            }).toList(),
                      ),
                    ),

                    // Floor
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: const Text('Floor',
                          style: TextStyle(color: Colors.white, fontSize: 11)),
                      subtitle: Text(table.floor,
                          style: TextStyle(
                              color: AppConstants.textSecondary, fontSize: 10)),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(
                            Icons.location_on, color: AppConstants.goldAccent,
                            size: 16),
                        onSelected: (floor) {
                          setState(() => table.floor = floor);
                          Navigator.pop(context);
                        },
                        itemBuilder: (context) =>
                            floors.map((floor) {
                              return PopupMenuItem(
                                value: floor,
                                child: Text(floor,
                                    style: const TextStyle(fontSize: 11)),
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel',
                        style: TextStyle(
                            color: AppConstants.textSecondary, fontSize: 11)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.goldAccent,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      // Apply new capacity
                      table.maxGuests = tempMaxGuests;
                      // Ensure guests don't exceed new capacity
                      if (table.guests > table.maxGuests) {
                        table.guests = table.maxGuests;
                      }
                      Navigator.pop(context);
                      setState(() {}); // refresh UI
                    },
                    child: const Text('Save', style: TextStyle(fontSize: 11)),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => tables.remove(table));
                      Navigator.pop(context);
                    },
                    child: Text('Delete',
                        style: TextStyle(
                            color: AppConstants.errorRed, fontSize: 11)),
                  ),
                ],
              );
            },
          ),
    );
  }
}