import 'dart:async';
import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../models/waiter_model.dart';
import '../widgets/table_card.dart';
import '../widgets/add_table_dialog.dart';
import '../widgets/add_waiter_dialog.dart';
import '../widgets/waiter_selection_dialog.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class TableManagementScreen extends StatefulWidget {
  @override
  _TableManagementScreenState createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> with TickerProviderStateMixin {
  List<TableModel> tables = [];
  List<WaiterModel> waiters = [];
  String selectedFilter = 'All';
  int? selectedSize;
  bool isLoading = true;

  // Real-time clock
  DateTime _currentTime = DateTime.now();
  late Timer _timer;

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadSampleData();

    // Initialize animations
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    // Update time every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _loadSampleData() {
    // Tables with different sizes
    tables = [
      TableModel(
        id: '1',
        number: '101',
        status: TableStatus.free,
        guests: 0,
        maxGuests: 2,
        amount: 0,
        shape: TableShape.square,
      ),
      TableModel(
        id: '2',
        number: '102',
        status: TableStatus.occupied,
        guests: 2,
        maxGuests: 2,
        amount: 450,
        waiterName: 'J',
        shape: TableShape.square,
      ),
      TableModel(
        id: '3',
        number: '103',
        status: TableStatus.free,
        guests: 0,
        maxGuests: 4,
        amount: 0,
        shape: TableShape.square,
      ),
      TableModel(
        id: '4',
        number: '104',
        status: TableStatus.occupied,
        guests: 3,
        maxGuests: 4,
        amount: 890,
        waiterName: 'S',
        shape: TableShape.square,
      ),
      TableModel(
        id: '5',
        number: '105',
        status: TableStatus.reserved,
        guests: 0,
        maxGuests: 6,
        amount: 0,
        reservedTime: '7:30 PM',
        shape: TableShape.rectangle,
      ),
      TableModel(
        id: '6',
        number: '106',
        status: TableStatus.occupied,
        guests: 4,
        maxGuests: 6,
        amount: 1250,
        waiterName: 'M',
        shape: TableShape.rectangle,
      ),
      TableModel(
        id: '7',
        number: '107',
        status: TableStatus.cleaning,
        guests: 0,
        maxGuests: 8,
        amount: 0,
        cleaningTime: '15 min',
        shape: TableShape.round,
      ),
      TableModel(
        id: '8',
        number: '108',
        status: TableStatus.free,
        guests: 0,
        maxGuests: 8,
        amount: 0,
        shape: TableShape.round,
      ),
      TableModel(
        id: '9',
        number: '109',
        status: TableStatus.occupied,
        guests: 6,
        maxGuests: 8,
        amount: 2340,
        waiterName: 'D',
        shape: TableShape.round,
      ),
      TableModel(
        id: '10',
        number: '110',
        status: TableStatus.billed,
        guests: 2,
        maxGuests: 4,
        amount: 560,
        shape: TableShape.square,
      ),
      TableModel(
        id: '11',
        number: '111',
        status: TableStatus.free,
        guests: 0,
        maxGuests: 6,
        amount: 0,
        shape: TableShape.rectangle,
      ),
      TableModel(
        id: '12',
        number: '112',
        status: TableStatus.free,
        guests: 0,
        maxGuests: 2,
        amount: 0,
        shape: TableShape.square,
      ),
    ];

    // Sample waiter data
    waiters = [
      WaiterModel(id: '1', name: 'John', code: 'W001', phone: '1234567890'),
      WaiterModel(id: '2', name: 'Jane', code: 'W002', phone: '0987654321'),
      WaiterModel(id: '3', name: 'Mike', code: 'W003', phone: '1122334455'),
      WaiterModel(id: '4', name: 'Sarah', code: 'W004', phone: '5566778899'),
      WaiterModel(id: '5', name: 'David', code: 'W005', phone: '9988776655'),
    ];

    setState(() {
      isLoading = false;
    });
  }

  List<TableModel> get filteredTables {
    return tables.where((table) {
      // Status filter
      if (selectedFilter != 'All') {
        TableStatus status;
        switch (selectedFilter) {
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

      // Size filter
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

    // Convert to 12-hour format
    int hour12 = _currentTime.hour > 12 ? _currentTime.hour - 12 : _currentTime.hour;
    hour12 = hour12 == 0 ? 12 : hour12;

    return '$hour12:$minute:$second $period';
  }

  String _getFormattedDate() {
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String month = months[_currentTime.month - 1];
    return '${_currentTime.day} $month ${_currentTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0a1929), // Very dark blue
              Color(0xFF1a2b3c), // Dark blue-gray
              Color(0xFF2a3b4d), // Medium blue-gray
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Header with company info and real-time clock
                  _buildHeader(),

                  // Filter chips
                  _buildFilterChips(),

                  // Size filter chips
                  _buildSizeFilterChips(),

                  // Tables count with animation
                  _buildTablesCount(),

                  // Tables Grid with dynamic sizing
                  Expanded(
                    child: isLoading
                        ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                        : AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      child: GridView.builder(
                        key: ValueKey(selectedFilter + (selectedSize?.toString() ?? '')),
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredTables.length,
                        itemBuilder: (context, index) {
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: TableCard(
                              table: filteredTables[index],
                              onTap: () => _showWaiterSelectionDialog(filteredTables[index]),
                              onLongPress: () => _showEditTableDialog(filteredTables[index]),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Bottom Action Bar with better visibility
                  _buildBottomActionBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.98),
            Colors.white.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SENTINIX TECH SOLUTIONS',
                  style: TextStyle(
                    color: Color(0xFF0a1929),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Table Management System',
                  style: TextStyle(
                    color: Color(0xFF2a3b4d),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0a1929), Color(0xFF2a3b4d)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      _getFormattedTime(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  _getFormattedDate(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All', Icons.table_restaurant, Colors.blue),
          _buildFilterChip('Free', Icons.check_circle, Colors.green),
          _buildFilterChip('Occupied', Icons.people, Colors.red),
          _buildFilterChip('Reserved', Icons.event_available, Colors.orange),
          _buildFilterChip('Cleaning', Icons.cleaning_services, Colors.blue),
          _buildFilterChip('Billed', Icons.receipt, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, Color color) {
    bool isSelected = selectedFilter == label;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : color,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedFilter = label;
          });
        },
        backgroundColor: Colors.white.withOpacity(0.95),
        selectedColor: color,
        checkmarkColor: Colors.white,
        elevation: 4,
        pressElevation: 8,
        shadowColor: color.withOpacity(0.5),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildSizeFilterChips() {
    return Container(
      height: 45,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildSizeChip('All', null, Icons.view_module, Colors.blue),
          _buildSizeChip('2 Seats', 2, Icons.weekend, Colors.green),
          _buildSizeChip('4 Seats', 4, Icons.chair, Colors.orange),
          _buildSizeChip('6 Seats', 6, Icons.table_restaurant, Colors.purple),
          _buildSizeChip('8+ Seats', 8, Icons.group, Colors.red),
        ],
      ),
    );
  }

  Widget _buildSizeChip(String label, int? size, IconData icon, Color color) {
    bool isSelected = selectedSize == size;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: 14,
          color: isSelected ? Colors.white : color,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedSize = selected ? size : null;
          });
        },
        backgroundColor: Colors.white.withOpacity(0.95),
        selectedColor: color,
        checkmarkColor: Colors.white,
        elevation: 3,
        pressElevation: 6,
      ),
    );
  }

  Widget _buildTablesCount() {
    int occupiedCount = tables.where((t) => t.status == TableStatus.occupied).length;
    int freeCount = tables.where((t) => t.status == TableStatus.free).length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${filteredTables.length} Tables Available',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 3,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '$freeCount Free',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '$occupiedCount Occupied',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'Main Floor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.98),
            Colors.white.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, -5),
            spreadRadius: 2,
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.add,
            label: 'Add Table',
            color: Colors.green,
            onTap: _showAddTableDialog,
          ),
          _buildActionButton(
            icon: Icons.person_add,
            label: 'Add Waiter',
            color: Colors.orange,
            onTap: _showAddWaiterDialog,
          ),
          _buildActionButton(
            icon: Icons.receipt,
            label: 'KOT',
            color: Colors.purple,
            onTap: () => _showComingSoon('KOT'),
          ),
          _buildActionButton(
            icon: Icons.print,
            label: 'Print Bill',
            color: Colors.teal,
            onTap: () => _showComingSoon('Print Bill'),
          ),
          _buildActionButton(
            icon: Icons.payment,
            label: 'Settle',
            color: Colors.red,
            onTap: () => _showComingSoon('Settle Bill'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.9), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF0a1929),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
              shadows: [
                Shadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature feature coming soon!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF0a1929),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(10),
      ),
    );
  }

  void _showAddTableDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTableDialog(
        onTableAdded: (newTable) {
          setState(() {
            tables.add(newTable);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Table ${newTable.number} added successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _showAddWaiterDialog() {
    showDialog(
      context: context,
      builder: (context) => AddWaiterDialog(
        onWaiterAdded: (newWaiter) {
          setState(() {
            waiters.add(newWaiter);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Waiter ${newWaiter.name} added successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _showEditTableDialog(TableModel table) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Table ${table.number}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0a1929),
                ),
              ),
              SizedBox(height: 20),
              _buildEditOption(
                'Status',
                table.status.toString().split('.').last,
                Icons.info,
                    () {
                  Navigator.pop(context);
                  _showStatusDialog(table);
                },
              ),
              _buildEditOption(
                'Guests',
                '${table.guests}/${table.maxGuests}',
                Icons.people,
                    () {
                  Navigator.pop(context);
                  _showGuestsDialog(table);
                },
              ),
              _buildEditOption(
                'Waiter',
                table.waiterName ?? 'Not Assigned',
                Icons.person,
                    () {
                  Navigator.pop(context);
                  _showWaiterSelectionDialog(table);
                },
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
                      onPressed: () {
                        setState(() {
                          tables.remove(table);
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Table ${table.number} deleted'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditOption(String label, String value, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xFF0a1929).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Color(0xFF0a1929), size: 20),
      ),
      title: Text(label),
      subtitle: Text(value),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showStatusDialog(TableModel table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TableStatus.values.map((status) {
            return ListTile(
              title: Text(status.toString().split('.').last),
              leading: Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
              ),
              onTap: () {
                setState(() {
                  table.status = status;
                  if (status == TableStatus.cleaning) {
                    table.cleaningTime = '20 min';
                  } else if (status == TableStatus.reserved) {
                    table.reservedTime = '7:30 PM';
                  }
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showGuestsDialog(TableModel table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Guests'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current: ${table.guests} / Max: ${table.maxGuests}'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.red, size: 32),
                  onPressed: () {
                    if (table.guests > 0) {
                      setState(() {
                        table.guests--;
                      });
                    }
                  },
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '${table.guests}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.green, size: 32),
                  onPressed: () {
                    if (table.guests < table.maxGuests) {
                      setState(() {
                        table.guests++;
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showWaiterSelectionDialog(TableModel table) {
    if (table.status == TableStatus.occupied) {
      _showTableOptionsDialog(table);
      return;
    }

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
            table.guests = table.maxGuests ~/ 2;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Waiter ${waiter.name} assigned to Table ${table.number}'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF0a1929).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.table_restaurant, color: Color(0xFF0a1929), size: 32),
              ),
              SizedBox(height: 12),
              Text(
                'Table ${table.number}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0a1929),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '${table.guests} Guests • ${table.waiterName ?? "No Waiter"}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              SizedBox(height: 20),
              _buildOptionTile(
                Icons.restaurant_menu,
                'Take Order',
                Colors.blue,
                    () {
                  Navigator.pop(context);
                  _showComingSoon('Order');
                },
              ),
              _buildOptionTile(
                Icons.person,
                'Change Waiter',
                Colors.orange,
                    () {
                  Navigator.pop(context);
                  _showWaiterSelectionDialog(table);
                },
              ),
              _buildOptionTile(
                Icons.edit,
                'Edit Table',
                Colors.green,
                    () {
                  Navigator.pop(context);
                  _showEditTableDialog(table);
                },
              ),
              _buildOptionTile(
                Icons.cleaning_services,
                'Mark as Cleaning',
                Colors.blue,
                    () {
                  setState(() {
                    table.status = TableStatus.cleaning;
                    table.cleaningTime = '20 min';
                  });
                  Navigator.pop(context);
                },
              ),
              _buildOptionTile(
                Icons.payment,
                'Settle Bill',
                Colors.purple,
                    () {
                  Navigator.pop(context);
                  _showComingSoon('Settle Bill');
                },
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }

  IconData _getStatusIcon(TableStatus status) {
    switch (status) {
      case TableStatus.free:
        return Icons.check_circle;
      case TableStatus.occupied:
        return Icons.people;
      case TableStatus.reserved:
        return Icons.event_available;
      case TableStatus.cleaning:
        return Icons.cleaning_services;
      case TableStatus.billed:
        return Icons.receipt;
    }
  }

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.free:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.cleaning:
        return Colors.blue;
      case TableStatus.billed:
        return Colors.purple;
    }
  }
}