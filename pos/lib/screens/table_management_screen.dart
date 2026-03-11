import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/table_with_seats.dart';
import '../models/seat_model.dart';
import '../widgets/table_card.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../utils/constants.dart';

class MobileTableScreen extends StatefulWidget {
  const MobileTableScreen({Key? key}) : super(key: key);

  @override
  State<MobileTableScreen> createState() => _MobileTableScreenState();
}

class _MobileTableScreenState extends State<MobileTableScreen> {
  List<TableWithSeats> tablesWithSeats = [];
  bool isLoading = true;

  String selectedStatus = 'All';
  String selectedSize = 'All';

  DateTime _currentTime = DateTime.now();
  late Timer _timer;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchTables();
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

  Future<void> _fetchTables() async {
    setState(() => isLoading = true);
    try {
      final fetched = await ApiService.fetchTablesWithAllSeats();
      setState(() {
        tablesWithSeats = fetched;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching tables: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load tables: $e'), backgroundColor: AppConstants.errorRed),
      );
      setState(() => isLoading = false);
    }
  }

  String _getFormattedTime() =>
      '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}';
  String _getFormattedDate() {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${_currentTime.day} ${months[_currentTime.month - 1]}';
  }

  bool _statusFilter(TableWithSeats item) {
    if (selectedStatus == 'All') return true;
    bool hasActiveSeats = item.seats.any((s) => s.status);
    return selectedStatus == 'Occupied' ? hasActiveSeats : !hasActiveSeats;
  }

  bool _sizeFilter(TableWithSeats item) {
    int seatCount = item.seats.length;
    if (selectedSize == 'All') return true;
    if (selectedSize == 'Less than 5') return seatCount < 5;
    if (selectedSize == 'More than 5') return seatCount > 5;
    return true;
  }

  List<TableWithSeats> get filteredTables {
    return tablesWithSeats.where((item) {
      if (_searchQuery.isNotEmpty && !item.table.name.contains(_searchQuery)) return false;
      if (!_statusFilter(item)) return false;
      if (!_sizeFilter(item)) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    int total = filteredTables.length;
    int occupied = filteredTables.where((t) => t.seats.any((s) => s.status)).length;
    int free = total - occupied;

    return Scaffold(
      backgroundColor: AppConstants.lightBackground,
      appBar: AppBar(
        backgroundColor: AppConstants.lightSurface,
        elevation: 1,
        toolbarHeight: 56,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('SENTINIX', style: TextStyle(color: AppConstants.primaryDark, fontSize: 17, fontWeight: FontWeight.bold)),
                Text(_getFormattedDate(), style: TextStyle(color: AppConstants.textSecondary, fontSize: 11)),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppConstants.lightBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppConstants.primaryColor.withOpacity(0.3), width: 1),
              ),
              child: Text(_getFormattedTime(), style: TextStyle(color: AppConstants.primaryDark, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.logout, color: AppConstants.primaryColor),
              onPressed: _confirmLogout,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildMobileStats(total, free, occupied),
            _buildMobileSearch(),
            _buildFilterRow(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
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
                onRefresh: _fetchTables,
                color: AppConstants.primaryColor,
                child: GridView.builder(
                  padding: const EdgeInsets.all(6),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.95,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: filteredTables.length,
                  itemBuilder: (context, index) {
                    final item = filteredTables[index];
                    return TableCard(
                      tableName: item.table.name,
                      seats: item.seats,
                      onTap: () => _showTableOptions(item),
                      onLongPress: () {
                        // Optional: edit table
                      },
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

  Future<void> _confirmLogout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppConstants.errorRed),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  Widget _buildMobileStats(int total, int free, int occupied) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _buildStatCard(Icons.table_restaurant, '$total', 'Total', [AppConstants.primaryLight, AppConstants.primaryColor]),
          const SizedBox(width: 4),
          _buildStatCard(Icons.check_circle, '$free', 'Free', [Colors.green.shade100, Colors.green]),
          const SizedBox(width: 4),
          _buildStatCard(Icons.people, '$occupied', 'Occ', [Colors.red.shade100, Colors.red]),
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
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
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
          border: Border.all(color: AppConstants.primaryColor.withOpacity(0.2), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: TextStyle(color: AppConstants.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Search tables...',
            hintStyle: TextStyle(color: AppConstants.textHint, fontSize: 11),
            prefixIcon: Icon(Icons.search, color: AppConstants.primaryColor, size: 18),
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
            ],
            onChanged: (v) => setState(() => selectedStatus = v!),
          )),
          const SizedBox(width: 6),
          Expanded(child: _buildDropdown(
            value: selectedSize,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All Sizes')),
              DropdownMenuItem(value: 'Less than 5', child: Text('Less than 5 seats')),
              DropdownMenuItem(value: 'More than 5', child: Text('More than 5 seats')),
            ],
            onChanged: (v) => setState(() => selectedSize = v!),
          )),
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
        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppConstants.lightSurface,
          style: TextStyle(color: AppConstants.textPrimary, fontSize: 13),
          icon: Icon(Icons.arrow_drop_down, color: AppConstants.primaryColor, size: 20),
          items: items,
          onChanged: onChanged,
          isExpanded: true,
        ),
      ),
    );
  }

  void _showTableOptions(TableWithSeats item) {
    bool allSeatsEmpty = !item.seats.any((s) => s.status); // all seats inactive
    bool hasOccupiedSeats = item.seats.any((s) => s.status);
    bool hasFreeSeats = item.seats.any((s) => !s.status);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Table ${item.table.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (allSeatsEmpty)
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Assign Waiter'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showWaiterSelectionDialog(item);
                },
              )
            else ...[
              if (hasOccupiedSeats)
                ListTile(
                  leading: const Icon(Icons.receipt),
                  title: const Text('Add Bill'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showAddBillDialog(item);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Change Waiter'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showWaiterSelectionDialog(item);
                },
              ),
              if (hasFreeSeats)
                ListTile(
                  leading: const Icon(Icons.group_add),
                  title: const Text('Add Guests'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showAddGuestsDialog(item);
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showWaiterSelectionDialog(TableWithSeats item) {
    // TODO: Implement waiter selection (needs waiters list and API)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Waiter selection coming soon')),
    );
  }

  void _showAddBillDialog(TableWithSeats item) {
    // TODO: Navigate to order page with table and seat IDs
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add bill coming soon')),
    );
  }

  void _showAddGuestsDialog(TableWithSeats item) {
    // TODO: Show seat selection for free seats only
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add guests coming soon')),
    );
  }
}