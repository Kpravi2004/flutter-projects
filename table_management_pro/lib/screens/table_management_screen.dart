import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../models/waiter_model.dart';
import '../widgets/table_card.dart';
import '../widgets/add_table_dialog.dart';
import '../widgets/add_waiter_dialog.dart';
import '../widgets/waiter_selection_dialog.dart';
import '../widgets/bill_split_dialog.dart';
import '../widgets/add_floor_dialog.dart';
import '../utils/constants.dart';
import '../utils/helper.dart';

class TableManagementScreen extends StatefulWidget {
  @override
  _TableManagementScreenState createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> {
  // Color palette
  final Color primaryPurple = Color(0xFF6B4E9E);
  final Color secondaryPurple = Color(0xFF8A6CC7);
  final Color deepBlue = Color(0xFF2C3A7A);
  final Color softLavender = Color(0xFFB8A9D9);
  final Color goldAccent = Color(0xFFE8C547);
  final Color creamWhite = Color(0xFFF8F4FF);

  List<TableModel> tables = [];
  List<WaiterModel> waiters = [];
  List<String> floors = ['Main Floor'];
  String selectedFloor = 'Main Floor';
  String selectedFilter = 'All';
  int? selectedSize;
  bool isLoading = true;

  // Track selected table for pink highlight
  String? selectedTableId;

  DateTime _currentTime = DateTime.now();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadSampleData();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _loadSampleData() {
    // Sample data with mixed statuses
    tables = [
      TableModel(id: '1', number: '101', status: TableStatus.free, guests: 0, maxGuests: 2, amount: 0, shape: TableShape.square, floor: 'Main Floor'),
      TableModel(id: '2', number: '102', status: TableStatus.occupied, guests: 2, maxGuests: 2, amount: 450, waiterName: 'J', shape: TableShape.square, floor: 'Main Floor'),
      TableModel(id: '3', number: '103', status: TableStatus.free, guests: 0, maxGuests: 4, amount: 0, shape: TableShape.square, floor: 'Main Floor'),
      TableModel(id: '4', number: '104', status: TableStatus.occupied, guests: 3, maxGuests: 4, amount: 890, waiterName: 'S', shape: TableShape.square, floor: 'Main Floor'),
      TableModel(id: '5', number: '105', status: TableStatus.reserved, guests: 0, maxGuests: 6, amount: 0, reservedTime: '7:30 PM', shape: TableShape.rectangle, floor: 'Main Floor'),
      TableModel(id: '6', number: '106', status: TableStatus.occupied, guests: 4, maxGuests: 6, amount: 1250, waiterName: 'M', shape: TableShape.rectangle, floor: 'Main Floor'),
      TableModel(id: '7', number: '107', status: TableStatus.cleaning, guests: 0, maxGuests: 8, amount: 0, cleaningTime: '15 min', shape: TableShape.round, floor: 'Main Floor'),
      TableModel(id: '8', number: '108', status: TableStatus.free, guests: 0, maxGuests: 8, amount: 0, shape: TableShape.round, floor: 'Main Floor'),
      TableModel(id: '9', number: '109', status: TableStatus.billed, guests: 2, maxGuests: 4, amount: 560, shape: TableShape.square, floor: 'Main Floor'),
      TableModel(id: '10', number: '110', status: TableStatus.free, guests: 0, maxGuests: 6, amount: 0, shape: TableShape.rectangle, floor: 'Main Floor'),
    ];

    waiters = [
      WaiterModel(id: '1', name: 'John', code: 'W001'),
      WaiterModel(id: '2', name: 'Jane', code: 'W002'),
      WaiterModel(id: '3', name: 'Mike', code: 'W003'),
      WaiterModel(id: '4', name: 'Sarah', code: 'W004'),
    ];

    setState(() => isLoading = false);
  }

  List<TableModel> get filteredTables {
    return tables.where((table) {
      if (selectedFloor != 'All Floors' && table.floor != selectedFloor) return false;

      if (selectedFilter != 'All') {
        TableStatus status;
        switch (selectedFilter) {
          case 'Free': status = TableStatus.free; break;
          case 'Occupied': status = TableStatus.occupied; break;
          case 'Reserved': status = TableStatus.reserved; break;
          case 'Cleaning': status = TableStatus.cleaning; break;
          case 'Billed': status = TableStatus.billed; break;
          default: return true;
        }
        if (table.status != status) return false;
      }

      if (selectedSize != null) {
        if (selectedSize == 8) {
          if (table.maxGuests < 8) return false;
        } else {
          if (table.maxGuests != selectedSize) return false;
        }
      }

      return true;
    }).toList();
  }

  String _getFormattedTime() {
    String hour = _currentTime.hour.toString().padLeft(2, '0');
    String minute = _currentTime.minute.toString().padLeft(2, '0');
    String second = _currentTime.second.toString().padLeft(2, '0');
    String period = _currentTime.hour >= 12 ? 'PM' : 'AM';
    int hour12 = _currentTime.hour > 12 ? _currentTime.hour - 12 : _currentTime.hour;
    hour12 = hour12 == 0 ? 12 : hour12;
    return '$hour12:$minute:$second $period';
  }

  String _getFormattedDate() {
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${_currentTime.day} ${months[_currentTime.month - 1]} ${_currentTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    int totalTables = filteredTables.length;
    int freeTables = filteredTables.where((t) => t.status == TableStatus.free).length;
    int occupiedTables = filteredTables.where((t) => t.status == TableStatus.occupied).length;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [deepBlue, primaryPurple, secondaryPurple],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Date/Time
              _buildHeader(),

              // Search Bar
              _buildSearchBar(),

              // Floor Selector
              _buildFloorSelector(),

              // Table Statistics
              _buildTableStats(totalTables, freeTables, occupiedTables),

              // Filter Chips
              _buildFilterChips(),

              // Tables Grid
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: goldAccent))
                    : GridView.builder(
                  padding: EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filteredTables.length,
                  itemBuilder: (context, index) {
                    final table = filteredTables[index];
                    return TableCard(
                      table: table,
                      isSelected: table.id == selectedTableId,
                      onTap: () {
                        setState(() {
                          selectedTableId = table.id;
                        });
                        _showTableActionDialog(table);
                      },
                      onLongPress: () => _showEditTableDialog(table),
                    );
                  },
                ),
              ),

              // Bottom Action Bar
              _buildBottomBar(),

              // Weather Info
              _buildWeatherInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: creamWhite.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SENTINIX',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: deepBlue,
                ),
              ),
              Text(
                'Premium Dining',
                style: TextStyle(
                  fontSize: 12,
                  color: primaryPurple,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryPurple, deepBlue],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  _getFormattedDate(),
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  _getFormattedTime(),
                  style: TextStyle(color: goldAccent, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: creamWhite.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Q Search',
          hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.white70, size: 18),
          border: InputBorder.none,
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildFloorSelector() {
    return Container(
      height: 45,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFloorChip('All Floors', Icons.dashboard, selectedFloor == 'All Floors', () {
            setState(() => selectedFloor = 'All Floors');
          }),
          ...floors.map((floor) => _buildFloorChip(floor, Icons.location_on, selectedFloor == floor, () {
            setState(() => selectedFloor = floor);
          })),
          _buildAddFloorChip(),
        ],
      ),
    );
  }

  Widget _buildFloorChip(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : primaryPurple),
        label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : primaryPurple)),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: creamWhite,
        selectedColor: primaryPurple,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildAddFloorChip() {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(Icons.add, size: 16, color: Colors.white),
        label: Text('Add Floor', style: TextStyle(fontSize: 12, color: Colors.white)),
        onPressed: _showAddFloorDialog,
        backgroundColor: goldAccent,
      ),
    );
  }

  Widget _buildTableStats(int total, int free, int occupied) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [softLavender.withOpacity(0.3), creamWhite.withOpacity(0.2)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.table_restaurant, '$total', 'Tables', deepBlue),
          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
          _buildStatItem(Icons.check_circle, '$free', 'Free', Colors.green.shade700),
          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
          _buildStatItem(Icons.people, '$occupied', 'Occ', Colors.red.shade700),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 40,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All', Icons.filter_list, Colors.blue, selectedFilter == 'All'),
          _buildFilterChip('Free', Icons.check_circle, Colors.green, selectedFilter == 'Free'),
          _buildFilterChip('Occupied', Icons.people, Colors.red, selectedFilter == 'Occupied'),
          _buildFilterChip('Reserved', Icons.event_available, Colors.orange, selectedFilter == 'Reserved'),
          _buildFilterChip('Cleaning', Icons.cleaning_services, Colors.blue, selectedFilter == 'Cleaning'),
          _buildFilterChip('Billed', Icons.receipt, Colors.purple, selectedFilter == 'Billed'),
          _buildSizeChip('2', 2, Icons.weekend, Colors.green),
          _buildSizeChip('4', 4, Icons.chair, Colors.orange),
          _buildSizeChip('6', 6, Icons.table_restaurant, Colors.purple),
          _buildSizeChip('8+', 8, Icons.group, Colors.red),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, Color color, bool isSelected) {
    return Padding(
      padding: EdgeInsets.only(right: 6),
      child: FilterChip(
        avatar: Icon(icon, size: 14, color: isSelected ? Colors.white : color),
        label: Text(label, style: TextStyle(fontSize: 11)),
        selected: isSelected,
        onSelected: (selected) => setState(() {
          selectedFilter = label;
          selectedTableId = null; // Clear selection when filtering
        }),
        backgroundColor: creamWhite,
        selectedColor: color,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
    );
  }

  Widget _buildSizeChip(String label, int? size, IconData icon, Color color) {
    bool isSelected = selectedSize == size;
    return Padding(
      padding: EdgeInsets.only(right: 6),
      child: FilterChip(
        avatar: Icon(icon, size: 12, color: isSelected ? Colors.white : color),
        label: Text(label, style: TextStyle(fontSize: 10)),
        selected: isSelected,
        onSelected: (selected) => setState(() {
          selectedSize = selected ? size : null;
          selectedTableId = null; // Clear selection when filtering
        }),
        backgroundColor: creamWhite,
        selectedColor: color,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: creamWhite.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(Icons.add, 'Add Table', Colors.green, _showAddTableDialog),
          _buildActionButton(Icons.person_add, 'Add Waiter', Colors.orange, _showAddWaiterDialog),
          _buildActionButton(Icons.receipt, 'KOT', Colors.purple, () => _showComingSoon('KOT')),
          _buildActionButton(Icons.print, 'Print', Colors.teal, () => _showComingSoon('Print')),
          _buildActionButton(Icons.payment, 'Settle', Colors.red, () => _showComingSoon('Settle')),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo() {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wb_sunny, color: goldAccent, size: 16),
          SizedBox(width: 4),
          Text(
            '31°C Sunny',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          SizedBox(width: 12),
          Container(width: 1, height: 12, color: Colors.white.withOpacity(0.3)),
          SizedBox(width: 12),
          Text('ENG', style: TextStyle(color: Colors.white70, fontSize: 11)),
          SizedBox(width: 4),
          Text('IN', style: TextStyle(color: goldAccent, fontSize: 11, fontWeight: FontWeight.bold)),
          SizedBox(width: 12),
          Container(width: 1, height: 12, color: Colors.white.withOpacity(0.3)),
          SizedBox(width: 12),
          Text('13:00', style: TextStyle(color: Colors.white, fontSize: 11)),
          SizedBox(width: 4),
          Text('18-02-2026', style: TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  void _showAddFloorDialog() {
    showDialog(
      context: context,
      builder: (context) => AddFloorDialog(
        onFloorAdded: (newFloor) {
          setState(() => floors.add(newFloor));
          _showSuccess('Floor "$newFloor" added');
        },
      ),
    );
  }

  void _showAddTableDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTableDialog(
        floors: floors,
        currentFloor: selectedFloor == 'All Floors' ? floors.first : selectedFloor,
        onTableAdded: (newTable) {
          setState(() {
            tables.add(newTable);
            selectedTableId = null; // Clear selection
          });
          _showSuccess('Table ${newTable.number} added');
        },
      ),
    );
  }

  void _showAddWaiterDialog() {
    showDialog(
      context: context,
      builder: (context) => AddWaiterDialog(
        onWaiterAdded: (newWaiter) {
          setState(() => waiters.add(newWaiter));
          _showSuccess('Waiter ${newWaiter.name} added');
        },
      ),
    );
  }

  void _showTableActionDialog(TableModel table) {
    if (table.status == TableStatus.free) {
      _showWaiterSelectionDialog(table);
    } else {
      _showTableOptionsDialog(table);
    }
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
            table.status = TableStatus.occupied;
            table.guests = table.maxGuests ~/ 2; // Set default guests
            selectedTableId = null; // Clear selection after assignment
          });
          Navigator.pop(context);
          _showSuccess('Waiter assigned');
        },
        onAddWaiter: () {
          Navigator.pop(context);
          _showAddWaiterDialog();
        },
      ),
    );
  }

  void _showTableOptionsDialog(TableModel table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Table ${table.number}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.restaurant_menu),
              title: Text('Take Order'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon('Order');
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Change Waiter'),
              onTap: () {
                Navigator.pop(context);
                _showWaiterSelectionDialog(table);
              },
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Settle Bill'),
              onTap: () {
                setState(() {
                  table.status = TableStatus.billed;
                  table.guests = 0;
                  table.waiterId = null;
                  table.waiterName = null;
                  selectedTableId = null;
                });
                Navigator.pop(context);
                _showSuccess('Table settled');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTableDialog(TableModel table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Table'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Status: ${table.status.toString().split('.').last}'),
              trailing: PopupMenuButton<TableStatus>(
                onSelected: (status) {
                  setState(() {
                    table.status = status;
                    selectedTableId = null;
                  });
                  Navigator.pop(context);
                },
                itemBuilder: (context) => TableStatus.values.map((s) {
                  return PopupMenuItem(value: s, child: Text(s.toString().split('.').last));
                }).toList(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                tables.remove(table);
                if (selectedTableId == table.id) selectedTableId = null;
              });
              Navigator.pop(context);
              _showSuccess('Table deleted');
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon'),
        backgroundColor: primaryPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}