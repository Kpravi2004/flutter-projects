import 'dart:async';
import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../models/waiter_model.dart';
import '../widgets/table_card.dart';
import '../widgets/add_table_dialog.dart';
import '../widgets/add_waiter_dialog.dart';
import '../widgets/waiter_selection_dialog.dart';
import '../widgets/bill_split_dialog.dart';
import '../utils/helpers.dart';

class TableManagementScreen extends StatefulWidget {
  const TableManagementScreen({Key? key}) : super(key: key);

  @override
  State<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> {
  // Color palette
  static const Color backgroundColor = Color(0xFF0A0E21);
  static const Color surfaceColor = Color(0xFF1A1F3A);
  static const Color accentColor = Color(0xFF00E5FF);

  List<TableModel> tables = [];
  List<WaiterModel> waiters = [];
  List<String> floors = ['Main Floor'];
  String selectedFloor = 'Main Floor';
  String selectedFilter = 'All';
  int? selectedSize;
  bool isLoading = true;

  DateTime _currentTime = DateTime.now();
  late Timer _timer;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Scroll controller to detect scroll direction
  final ScrollController _scrollController = ScrollController();
  bool _isFilterVisible = true;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _loadSampleData();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > _lastScrollOffset &&
        _scrollController.offset > 50 &&
        _isFilterVisible) {
      // Scrolling down - hide filters
      setState(() {
        _isFilterVisible = false;
      });
    } else if (_scrollController.offset < _lastScrollOffset &&
        !_isFilterVisible) {
      // Scrolling up - show filters
      setState(() {
        _isFilterVisible = true;
      });
    }
    _lastScrollOffset = _scrollController.offset;
  }

  @override
  void dispose() {
    _timer.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadSampleData() {
    // All tables initially free
    tables = [
      TableModel(id: '1', number: '101', status: TableStatus.free, guests: 0, maxGuests: 2, amount: 0, floor: 'Main Floor'),
      TableModel(id: '2', number: '102', status: TableStatus.free, guests: 0, maxGuests: 2, amount: 0, floor: 'Main Floor'),
      TableModel(id: '3', number: '103', status: TableStatus.free, guests: 0, maxGuests: 4, amount: 0, floor: 'Main Floor'),
      TableModel(id: '4', number: '104', status: TableStatus.free, guests: 0, maxGuests: 4, amount: 0, floor: 'Main Floor'),
      TableModel(id: '5', number: '105', status: TableStatus.free, guests: 0, maxGuests: 6, amount: 0, floor: 'Main Floor'),
      TableModel(id: '6', number: '106', status: TableStatus.free, guests: 0, maxGuests: 6, amount: 0, floor: 'Main Floor'),
      TableModel(id: '7', number: '107', status: TableStatus.free, guests: 0, maxGuests: 8, amount: 0, floor: 'Main Floor'),
      TableModel(id: '8', number: '108', status: TableStatus.free, guests: 0, maxGuests: 8, amount: 0, floor: 'Main Floor'),
      TableModel(id: '9', number: '109', status: TableStatus.free, guests: 0, maxGuests: 4, amount: 0, floor: 'Main Floor'),
      TableModel(id: '10', number: '110', status: TableStatus.free, guests: 0, maxGuests: 6, amount: 0, floor: 'Main Floor'),
      TableModel(id: '11', number: '111', status: TableStatus.free, guests: 0, maxGuests: 2, amount: 0, floor: 'Main Floor'),
      TableModel(id: '12', number: '112', status: TableStatus.free, guests: 0, maxGuests: 4, amount: 0, floor: 'Main Floor'),
      TableModel(id: '13', number: '113', status: TableStatus.free, guests: 0, maxGuests: 6, amount: 0, floor: 'Main Floor'),
      TableModel(id: '14', number: '114', status: TableStatus.free, guests: 0, maxGuests: 8, amount: 0, floor: 'Main Floor'),
      TableModel(id: '15', number: '115', status: TableStatus.free, guests: 0, maxGuests: 4, amount: 0, floor: 'Main Floor'),
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
      // Floor filter
      if (selectedFloor != 'All Floors' && table.floor != selectedFloor) return false;

      // Status filter
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

      // Size filter
      if (selectedSize != null && table.maxGuests != selectedSize) return false;

      // Search filter
      if (_searchQuery.isNotEmpty && !table.number.contains(_searchQuery)) return false;

      return true;
    }).toList();
  }

  String _getFormattedTime() {
    return '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}';
  }

  String _getFormattedDate() {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${_currentTime.day} ${months[_currentTime.month - 1]} ${_currentTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    int totalTables = filteredTables.length;
    int freeTables = filteredTables.where((t) => t.status == TableStatus.free).length;
    int occupiedTables = filteredTables.where((t) => t.status == TableStatus.occupied).length;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header (Always visible)
            _buildHeader(),

            // Stats Row with Action Buttons (Always visible)
            _buildStatsRow(totalTables, freeTables, occupiedTables),

            // Animated Filter Section (Collapsible)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isFilterVisible ? 120 : 0,
              child: _isFilterVisible
                  ? Column(
                children: [
                  _buildSearchAndFloor(),
                  _buildFilterChips(),
                ],
              )
                  : null,
            ),

            // Tables Grid with scroll controller
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                color: accentColor,
                backgroundColor: surfaceColor,
                child: GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredTables.length,
                  itemBuilder: (context, index) {
                    final table = filteredTables[index];
                    return TableCard(
                      table: table,
                      onTap: () => _showTableOptions(table),
                      onLongPress: () => _showEditTableDialog(table),
                    );
                  },
                ),
              ),
            ),

            // Weather Info (Optional)
            _buildWeatherInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SENTINIX',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Table Management',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(
                  _getFormattedDate(),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Container(width: 1, height: 20, color: Colors.white24),
                const SizedBox(width: 8),
                Text(
                  _getFormattedTime(),
                  style: const TextStyle(color: accentColor, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int total, int free, int occupied) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Total Tables
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.table_restaurant, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$total',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Total Tables',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Free Tables
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$free',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Free',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Occupied Tables
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$occupied',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Occupied',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Action Buttons
          _buildActionButton(Icons.add, 'Add Table', Colors.green, _showAddTableDialog),
          const SizedBox(width: 8),
          _buildActionButton(Icons.person_add, 'Add Waiter', accentColor, _showAddWaiterDialog),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFloor() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search tables...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                  prefixIcon: Icon(Icons.search, color: accentColor, size: 16),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Floor Selector
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildFloorChip('All', 'All Floors'),
                ...floors.map((floor) => _buildFloorChip(floor, floor)),
                _buildAddFloorChip(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorChip(String label, String value) {
    bool isSelected = selectedFloor == value;
    return GestureDetector(
      onTap: () => setState(() => selectedFloor = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 11,
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
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Icon(Icons.add, color: accentColor, size: 16),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          _buildSizeChip('8', 8, Icons.group, Colors.red),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, Color color, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        avatar: Icon(icon, size: 12, color: isSelected ? Colors.white : color),
        label: Text(label, style: const TextStyle(fontSize: 10)),
        selected: isSelected,
        onSelected: (selected) => setState(() => selectedFilter = label),
        backgroundColor: surfaceColor,
        selectedColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  Widget _buildSizeChip(String label, int size, IconData icon, Color color) {
    bool isSelected = selectedSize == size;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        avatar: Icon(icon, size: 10, color: isSelected ? Colors.white : color),
        label: Text(label, style: const TextStyle(fontSize: 9)),
        selected: isSelected,
        onSelected: (selected) => setState(() => selectedSize = selected ? size : null),
        backgroundColor: surfaceColor,
        selectedColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
    );
  }

  Widget _buildWeatherInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wb_sunny, color: accentColor, size: 14),
          const SizedBox(width: 4),
          const Text(
            '31°C',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(width: 4),
          Container(width: 1, height: 10, color: Colors.white24),
          const SizedBox(width: 4),
          const Text(
            'Mostly cloudy',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  void _showAddFloorDialog() {
    TextEditingController floorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Floor'),
        content: TextField(
          controller: floorController,
          decoration: const InputDecoration(
            labelText: 'Floor Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (floorController.text.isNotEmpty) {
                setState(() {
                  floors.add(floorController.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
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
          setState(() => tables.add(newTable));
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
        },
      ),
    );
  }

  void _showTableOptions(TableModel table) {
    if (table.status == TableStatus.free) {
      _showWaiterSelectionDialog(table);
    } else {
      _showTableActionsDialog(table);
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
      builder: (context) => AlertDialog(
        title: Text('Select Guests for Table ${table.number}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Max Capacity: ${table.maxGuests} guests'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: List.generate(table.maxGuests, (index) {
                int count = index + 1;
                return ChoiceChip(
                  label: Text('$count'),
                  selected: table.guests == count,
                  onSelected: (selected) {
                    setState(() {
                      table.guests = count;
                      table.status = TableStatus.occupied;
                    });
                    Navigator.pop(context);

                    // Ask for bill split if large table
                    if (table.maxGuests >= 6 && count >= 4) {
                      _showBillSplitOption(table);
                    }
                  },
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
      builder: (context) => AlertDialog(
        title: const Text('Split Bill?'),
        content: const Text('Do you want to split the bill for multiple families?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
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
        onBillsCreated: (bills) {
          setState(() {
            table.bills = bills;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showTableActionsDialog(TableModel table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Table ${table.number}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('View Orders / Add Bill'),
              onTap: () {
                Navigator.pop(context);
                _showBillEntryDialog(table);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Change Waiter'),
              onTap: () {
                Navigator.pop(context);
                _showWaiterSelectionDialog(table);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Split Bill'),
              onTap: () {
                Navigator.pop(context);
                _showBillSplitDialog(table);
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Settle Bill'),
              onTap: () {
                setState(() {
                  table.status = TableStatus.billed;
                  table.amount = 0;
                  table.guests = 0;
                  table.waiterId = null;
                  table.waiterName = null;
                  table.bills = null;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBillEntryDialog(TableModel table) {
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Bill Amount'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount',
            border: OutlineInputBorder(),
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                setState(() {
                  table.amount = double.parse(amountController.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditTableDialog(TableModel table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Table ${table.number}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Status'),
              subtitle: Text(table.status.toString().split('.').last),
              trailing: PopupMenuButton<TableStatus>(
                onSelected: (status) {
                  setState(() => table.status = status);
                  Navigator.pop(context);
                },
                itemBuilder: (context) => TableStatus.values.map((status) {
                  return PopupMenuItem(
                    value: status,
                    child: Text(status.toString().split('.').last),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: const Text('Floor'),
              subtitle: Text(table.floor),
              trailing: PopupMenuButton<String>(
                onSelected: (floor) {
                  setState(() => table.floor = floor);
                  Navigator.pop(context);
                },
                itemBuilder: (context) => floors.map((floor) {
                  return PopupMenuItem(
                    value: floor,
                    child: Text(floor),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                tables.remove(table);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}