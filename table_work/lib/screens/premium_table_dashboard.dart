import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../models/waiter_model.dart';
import '../models/order_model.dart';
import '../widgets/premium_table_card.dart';
import '../widgets/premium_stats_card.dart';
import '../widgets/premium_floor_plan.dart';
import '../widgets/premium_waiter_panel.dart';
import '../widgets/premium_reservation_dialog.dart';
import '../widgets/premium_bill_split_dialog.dart';
import '../widgets/premium_analytics_chart.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class PremiumTableDashboard extends StatefulWidget {
  const PremiumTableDashboard({Key? key}) : super(key: key);

  @override
  State<PremiumTableDashboard> createState() => _PremiumTableDashboardState();
}

class _PremiumTableDashboardState extends State<PremiumTableDashboard> with TickerProviderStateMixin {
  // Premium Color Palette
  static const Color backgroundColor = Color(0xFF0A0E21);
  static const Color surfaceColor = Color(0xFF1A1F3A);
  static const Color accentColor = Color(0xFF00E5FF);
  static const Color goldColor = Color(0xFFFFD700);
  static const Color successColor = Color(0xFF00E676);
  static const Color warningColor = Color(0xFFFFB74D);
  static const Color errorColor = Color(0xFFFF5252);
  static const Color purpleAccent = Color(0xFF7C4DFF);

  late List<TableModel> tables;
  late List<WaiterModel> waiters;
  List<String> floors = ['Main Floor', 'Mezzanine', 'Rooftop', 'Private Room'];
  String selectedFloor = 'Main Floor';
  String selectedView = 'grid'; // 'floor', 'grid', 'list'
  bool isLoading = true;
  bool showAnalytics = false;

  DateTime _currentTime = DateTime.now();
  late Timer _timer;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    super.dispose();
  }

  void _loadSampleData() {
    tables = [
      TableModel(
        id: '1',
        number: 'VIP 1',
        status: TableStatus.occupied,
        guests: 4,
        maxGuests: 4,
        amount: 2450,
        waiterId: '1',
        waiterName: 'James',
        shape: TableShape.round,
        floor: 'Main Floor',
      ),
      TableModel(
        id: '2',
        number: 'T01',
        status: TableStatus.free,
        guests: 0,
        maxGuests: 2,
        amount: 0,
        shape: TableShape.square,
        floor: 'Main Floor',
      ),
      TableModel(
        id: '3',
        number: 'T02',
        status: TableStatus.reserved,
        guests: 0,
        maxGuests: 4,
        amount: 0,
        waiterId: '3',
        waiterName: 'Sarah',
        shape: TableShape.square,
        floor: 'Main Floor',
        reservedTime: '7:30 PM',
      ),
      TableModel(
        id: '4',
        number: 'T03',
        status: TableStatus.occupied,
        guests: 6,
        maxGuests: 6,
        amount: 5670,
        waiterId: '2',
        waiterName: 'Emma',
        shape: TableShape.rectangle,
        floor: 'Main Floor',
      ),
    ];

    waiters = [
      WaiterModel(id: '1', name: 'James Rodriguez', code: 'W001', rating: 4.9, activeOrders: 3),
      WaiterModel(id: '2', name: 'Emma Watson', code: 'W002', rating: 4.8, activeOrders: 2),
      WaiterModel(id: '3', name: 'Sarah Chen', code: 'W003', rating: 5.0, activeOrders: 1),
    ];

    setState(() => isLoading = false);
  }

  List<TableModel> get filteredTables {
    return tables.where((table) {
      if (selectedFloor != 'All Floors' && table.floor != selectedFloor) return false;
      if (_searchQuery.isNotEmpty && !table.number.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      return true;
    }).toList();
  }

  Map<String, dynamic> get dashboardStats {
    int total = tables.length;
    int free = tables.where((t) => t.status == TableStatus.free).length;
    int occupied = tables.where((t) => t.status == TableStatus.occupied).length;
    int reserved = tables.where((t) => t.status == TableStatus.reserved).length;
    double revenue = tables.fold(0, (sum, table) => sum + table.amount);

    return {
      'total': total,
      'free': free,
      'occupied': occupied,
      'reserved': reserved,
      'revenue': revenue,
    };
  }

  String _getFormattedTime() {
    return '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}:${_currentTime.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final stats = dashboardStats;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar
            _buildSidebar(),

            // Main Content
            Expanded(
              child: Column(
                children: [
                  _buildHeader(stats),
                  _buildControlBar(),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildGridView(),
                  ),
                ],
              ),
            ),

            // Right Panel
            if (screenWidth > 1200)
              _buildRightPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 80,
      color: surfaceColor,
      child: Column(
        children: [
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.table_restaurant, color: Colors.black, size: 24),
          ),
          const SizedBox(height: 40),
          _buildNavIcon(Icons.dashboard, true),
          _buildNavIcon(Icons.table_chart, false),
          _buildNavIcon(Icons.people, false),
          const Spacer(),
          const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: isSelected ? accentColor : Colors.white54),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildStatBox('Total', '${stats['total']}', Icons.table_restaurant, accentColor),
                const SizedBox(width: 16),
                _buildStatBox('Free', '${stats['free']}', Icons.check_circle, successColor),
                const SizedBox(width: 16),
                _buildStatBox('Occupied', '${stats['occupied']}', Icons.people, errorColor),
                const SizedBox(width: 16),
                _buildStatBox('Revenue', '₹${stats['revenue']}', Icons.currency_rupee, goldColor),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getFormattedTime(),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Floor Selector
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildFloorChip('All Floors', 'All Floors'),
                ...floors.map((floor) => _buildFloorChip(floor, floor)),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Search
          Expanded(
            child: Container(
              height: 44,
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
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: Icon(Icons.search, color: accentColor),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // View Toggle
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildViewToggle(Icons.map, 'floor'),
                _buildViewToggle(Icons.grid_view, 'grid'),
                _buildViewToggle(Icons.view_list, 'list'),
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewToggle(IconData icon, String view) {
    bool isSelected = selectedView == view;
    return GestureDetector(
      onTap: () => setState(() => selectedView = view),
      child: Container(
        width: 44,
        child: Icon(
          icon,
          color: isSelected ? accentColor : Colors.white54,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredTables.length,
      itemBuilder: (context, index) {
        final table = filteredTables[index];
        return PremiumTableCard(
          table: table,
          onTap: () => _showTableActions(table),
          onLongPress: () {},
          accentColor: accentColor,
          surfaceColor: surfaceColor,
        );
      },
    );
  }

  Widget _buildRightPanel() {
    return Container(
      width: 300,
      color: surfaceColor,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Active Staff',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: waiters.length,
              itemBuilder: (context, index) {
                final waiter = waiters[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: accentColor.withOpacity(0.2),
                    child: Text(
                      waiter.name[0],
                      style: TextStyle(color: accentColor),
                    ),
                  ),
                  title: Text(waiter.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    '${waiter.activeOrders} orders • ★ ${waiter.rating}',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTableActions(TableModel table) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person_add, color: accentColor),
              title: const Text('Assign Waiter', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.event_available, color: warningColor),
              title: const Text('Make Reservation', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}