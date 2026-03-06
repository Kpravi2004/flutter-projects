import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/bill_view_dialog.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({Key? key}) : super(key: key);

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _pendingBills = [];
  List<dynamic> _completedBills = [];
  List<dynamic> _filteredCompletedBills = [];
  bool _isLoading = false;

  // Search and filter
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _fetchBills();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _applyFilters();
    }
  }

  Future<void> _fetchBills() async {
    setState(() => _isLoading = true);
    try {
      List<dynamic> allBills = await ApiService.fetchAllBills();
      setState(() {
        _pendingBills = allBills.where((b) => b['status'] == 'pending').toList();
        _completedBills = allBills.where((b) => b['status'] == 'completed').toList();
        _applyFilters();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bills: $e'), backgroundColor: AppConstants.errorRed),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    // Filter completed bills by date range and search query
    _filteredCompletedBills = _completedBills.where((bill) {
      // Date range filter
      if (_selectedDateRange != null) {
        DateTime billDate = DateTime.parse(bill['dateTime']);
        if (billDate.isBefore(_selectedDateRange!.start) || billDate.isAfter(_selectedDateRange!.end)) {
          return false;
        }
      }
      // Search query filter (by bill ID or item name)
      if (_searchQuery.isNotEmpty) {
        bool idMatch = bill['id'].toString().contains(_searchQuery);
        bool itemMatch = (bill['items'] as List).any((item) =>
            item['productName'].toLowerCase().contains(_searchQuery.toLowerCase()));
        return idMatch || itemMatch;
      }
      return true;
    }).toList();
  }

  Future<void> _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppConstants.tealPrimary,
              onPrimary: Colors.white,
              surface: AppConstants.lightSurface,
              onSurface: AppConstants.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _applyFilters();
      });
    }
  }

  void _clearDateRange() {
    setState(() {
      _selectedDateRange = null;
      _applyFilters();
    });
  }

  Future<void> _confirmBill(Map<String, dynamic> bill) async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Bill'),
        content: Text('Are you sure you want to mark bill #${bill['id']} as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.successGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.confirmBill(bill['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bill confirmed'), backgroundColor: AppConstants.successGreen),
        );
        _fetchBills(); // refresh lists
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to confirm bill: $e'), backgroundColor: AppConstants.errorRed),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.lightBackground,
      appBar: AppBar(
        title: const Text('Bills'),
        backgroundColor: AppConstants.tealPrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          // Pending bills tab
          _buildPendingTab(),
          // Completed bills tab with filters
          _buildCompletedTab(),
        ],
      ),
    );
  }

  Widget _buildPendingTab() {
    if (_pendingBills.isEmpty) {
      return Center(
        child: Text(
          'No pending bills',
          style: TextStyle(color: AppConstants.textSecondary, fontSize: 16),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchBills,
      color: AppConstants.tealPrimary,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _pendingBills.length,
        itemBuilder: (context, index) {
          final bill = _pendingBills[index];
          return _buildBillCard(bill, isPending: true);
        },
      ),
    );
  }

  Widget _buildCompletedTab() {
    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.all(8),
          color: AppConstants.lightSurface,
          child: Row(
            children: [
              // Search field
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _applyFilters();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by bill # or item...',
                      hintStyle: TextStyle(color: AppConstants.textHint, fontSize: 12),
                      prefixIcon: Icon(Icons.search, color: AppConstants.tealPrimary, size: 18),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Date range picker button
              OutlinedButton.icon(
                onPressed: _selectDateRange,
                icon: Icon(Icons.date_range, size: 18),
                label: Text(
                  _selectedDateRange == null
                      ? 'Select Dates'
                      : '${DateFormat('dd/MM/yy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yy').format(_selectedDateRange!.end)}',
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppConstants.tealPrimary,
                  side: BorderSide(color: AppConstants.tealPrimary.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              if (_selectedDateRange != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.clear, color: AppConstants.errorRed, size: 18),
                  onPressed: _clearDateRange,
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: _filteredCompletedBills.isEmpty
              ? Center(
            child: Text(
              'No completed bills match your filters',
              style: TextStyle(color: AppConstants.textSecondary, fontSize: 16),
            ),
          )
              : RefreshIndicator(
            onRefresh: _fetchBills,
            color: AppConstants.tealPrimary,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filteredCompletedBills.length,
              itemBuilder: (context, index) {
                final bill = _filteredCompletedBills[index];
                return _buildBillCard(bill, isPending: false);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBillCard(Map<String, dynamic> bill, {required bool isPending}) {
    final dateTime = DateTime.parse(bill['dateTime']);
    final items = List<Map<String, dynamic>>.from(bill['items']);
    final itemCount = items.length;
    final total = bill['totalAmount'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status indicator
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isPending ? AppConstants.warningOrange.withOpacity(0.2) : AppConstants.successGreen.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPending ? Icons.pending : Icons.check_circle,
                    color: isPending ? AppConstants.warningOrange : AppConstants.successGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bill #${bill['id']}',
                        style: TextStyle(
                          color: AppConstants.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(dateTime),
                        style: TextStyle(color: AppConstants.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isPending ? AppConstants.warningOrange : AppConstants.successGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '₹${total.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Item summary
            Row(
              children: [
                Icon(Icons.receipt, size: 16, color: AppConstants.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '$itemCount item${itemCount != 1 ? 's' : ''}',
                  style: TextStyle(color: AppConstants.textSecondary, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons (text buttons instead of icons)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  label: 'View',
                  icon: Icons.visibility,
                  color: AppConstants.tealPrimary,
                  onPressed: () => _viewBill(bill),
                ),
                const SizedBox(width: 8),
                if (isPending) ...[
                  _buildActionButton(
                    label: 'Edit',
                    icon: Icons.edit,
                    color: AppConstants.coralAccent,
                    onPressed: () => _editBill(bill),
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    label: 'Confirm',
                    icon: Icons.check_circle,
                    color: AppConstants.successGreen,
                    onPressed: () => _confirmBill(bill),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(70, 32),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  void _viewBill(Map<String, dynamic> bill) {
    showDialog(
      context: context,
      builder: (ctx) => BillViewDialog(bill: bill),
    );
  }

  void _editBill(Map<String, dynamic> bill) {
    // TODO: Implement bill edit page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feature coming soon')),
    );
  }
}