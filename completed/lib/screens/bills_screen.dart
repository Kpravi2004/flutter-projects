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
    _filteredCompletedBills = _completedBills.where((bill) {
      if (_selectedDateRange != null) {
        DateTime billDate = DateTime.parse(bill['dateTime']);
        if (billDate.isBefore(_selectedDateRange!.start) || billDate.isAfter(_selectedDateRange!.end)) {
          return false;
        }
      }
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
    String? selectedPaymentMethod = 'Cash'; // default
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Confirm Bill'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to mark bill #${bill['id']} as completed?'),
                const SizedBox(height: 16),
                const Text('Payment Method:'),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: selectedPaymentMethod,
                  items: const [
                    DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'Card', child: Text('Card')),
                    DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    selectedPaymentMethod = value;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
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
          );
        },
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.confirmBill(bill['id'], paymentMethod: selectedPaymentMethod);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bill confirmed'), backgroundColor: AppConstants.successGreen),
        );
        _fetchBills();
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
      backgroundColor: const Color(0xFFF8F5F0), // parchment-like background
      appBar: AppBar(
        title: const Text('Bills', style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w400)),
        backgroundColor: const Color(0xFF2C3E50), // dark blue-gray
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
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
          _buildPendingTab(),
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
          style: TextStyle(color: AppConstants.textSecondary, fontSize: 16, fontStyle: FontStyle.italic),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchBills,
      color: AppConstants.tealPrimary,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _pendingBills.length,
        itemBuilder: (context, index) {
          final bill = _pendingBills[index];
          return _buildClassicBillCard(bill, isPending: true);
        },
      ),
    );
  }

  Widget _buildCompletedTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: const Color(0xFFF8F5F0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
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
                      hintText: 'Search bills...',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      prefixIcon: Icon(Icons.search, color: AppConstants.tealPrimary, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _selectDateRange,
                icon: Icon(Icons.date_range, size: 18, color: AppConstants.tealPrimary),
                label: Text(
                  _selectedDateRange == null ? 'Filter Dates' : '${DateFormat('dd/MM/yy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yy').format(_selectedDateRange!.end)}',
                  style: TextStyle(color: AppConstants.tealPrimary, fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppConstants.tealPrimary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              if (_selectedDateRange != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.clear, color: Colors.red, size: 20),
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
              'No completed bills match',
              style: TextStyle(color: AppConstants.textSecondary, fontSize: 16, fontStyle: FontStyle.italic),
            ),
          )
              : RefreshIndicator(
            onRefresh: _fetchBills,
            color: AppConstants.tealPrimary,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _filteredCompletedBills.length,
              itemBuilder: (context, index) {
                final bill = _filteredCompletedBills[index];
                return _buildClassicBillCard(bill, isPending: false);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassicBillCard(Map<String, dynamic> bill, {required bool isPending}) {
    final dateTime = DateTime.parse(bill['dateTime']);
    final items = List<Map<String, dynamic>>.from(bill['items']);
    final itemCount = items.length;
    final total = bill['totalAmount'];
    final tableNumbers = bill['tableNumbers'] ?? 'N/A';
    final waiterNames = bill['waiterNames'] ?? 'N/A';
    final paymentMethod = bill['paymentMethod'] ?? 'Not set';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isPending ? AppConstants.warningOrange.withOpacity(0.5) : AppConstants.successGreen.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with vintage style
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isPending ? AppConstants.warningOrange.withOpacity(0.1) : AppConstants.successGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPending ? Icons.hourglass_empty : Icons.check,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Georgia',
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(dateTime),
                        style: TextStyle(color: AppConstants.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPending ? AppConstants.warningOrange : AppConstants.successGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '₹${total.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Details in a two-column layout
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Table', tableNumbers),
                      _buildDetailRow('Waiter', waiterNames),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Items', '$itemCount'),
                      _buildDetailRow('Payment', paymentMethod),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  label: 'View',
                  icon: Icons.receipt,
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
                    icon: Icons.check,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label:', style: TextStyle(color: AppConstants.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(color: AppConstants.textPrimary))),
        ],
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
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(70, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
    // Placeholder for edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feature coming soon')),
    );
  }
}