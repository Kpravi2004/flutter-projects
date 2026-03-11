import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/bill_view_dialog.dart';
import 'bill_order_page.dart';
import 'bill_edit_page.dart';

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

  String _searchQuery = '';
  DateTime? _fromDate;
  DateTime? _toDate;
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
        _pendingBills = allBills.where((b) => b['status'] == 'pending').toList()
          ..sort((a, b) => DateTime.parse(a['dateTime']).compareTo(DateTime.parse(b['dateTime']))); // oldest first

        _completedBills = allBills.where((b) => b['status'] == 'completed').toList()
          ..sort((a, b) => DateTime.parse(b['dateTime']).compareTo(DateTime.parse(a['dateTime']))); // newest first

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
      DateTime billDate = DateTime.parse(bill['dateTime']);
      if (_fromDate != null && billDate.isBefore(_fromDate!)) return false;
      if (_toDate != null && billDate.isAfter(_toDate!.add(const Duration(days: 1)))) return false;
      if (_searchQuery.isNotEmpty) {
        bool idMatch = bill['id'].toString().contains(_searchQuery);
        bool itemMatch = (bill['items'] as List).any((item) =>
            item['productName'].toLowerCase().contains(_searchQuery.toLowerCase()));
        return idMatch || itemMatch;
      }
      return true;
    }).toList();
  }

  Future<void> _selectFromDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
        _fromDate = picked;
        _applyFilters();
      });
    }
  }

  Future<void> _selectToDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
        _toDate = picked;
        _applyFilters();
      });
    }
  }

  void _clearDates() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _applyFilters();
    });
  }

  Future<void> _confirmBill(Map<String, dynamic> bill) async {
    String? selectedPaymentMethod = 'Cash';
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

  void _addProductToBill(Map<String, dynamic> bill) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillOrderPage(
          billId: bill['id'],
          existingItems: List<Map<String, dynamic>>.from(bill['items']),
        ),
      ),
    );
    if (result == true) {
      _fetchBills();
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
      backgroundColor: const Color(0xFFF8F5F0),
      appBar: AppBar(
        title: const Text('Bills', style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w400)),
        backgroundColor: const Color(0xFF2C3E50),
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
          return _buildBillCard(bill, isPending: true);
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
          child: Column(
            children: [
              // Search bar with thicker border
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.5), width: 2),
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
                    hintText: 'Search bills by ID or item...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, color: AppConstants.tealPrimary, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // From and To date buttons with thicker borders
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectFromDate,
                      icon: Icon(Icons.date_range, size: 18, color: AppConstants.tealPrimary),
                      label: Text(
                        _fromDate == null ? 'From Date' : 'From: ${DateFormat('dd/MM/yy').format(_fromDate!)}',
                        style: TextStyle(color: AppConstants.tealPrimary, fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppConstants.tealPrimary, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectToDate,
                      icon: Icon(Icons.date_range, size: 18, color: AppConstants.tealPrimary),
                      label: Text(
                        _toDate == null ? 'To Date' : 'To: ${DateFormat('dd/MM/yy').format(_toDate!)}',
                        style: TextStyle(color: AppConstants.tealPrimary, fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppConstants.tealPrimary, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  if (_fromDate != null || _toDate != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.red, size: 20),
                      onPressed: _clearDates,
                    ),
                  ],
                ],
              ),
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
    final tableNumbers = bill['tableNumbers'] ?? 'N/A';
    final waiterNames = bill['waiterNames'] ?? 'N/A';
    final paymentMethod = bill['paymentMethod'] ?? 'Not set';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPending ? AppConstants.warningOrange.withOpacity(0.7) : AppConstants.successGreen.withOpacity(0.7),
          width: 2.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with status icon, bill number, date, total, and view button (for completed)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isPending ? AppConstants.warningOrange.withOpacity(0.15) : AppConstants.successGreen.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPending ? Icons.hourglass_empty : Icons.check_circle,
                    color: isPending ? AppConstants.warningOrange : AppConstants.successGreen,
                    size: 22,
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
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(dateTime),
                        style: TextStyle(color: AppConstants.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Total amount and view button (for completed)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isPending ? AppConstants.warningOrange : AppConstants.successGreen,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: (isPending ? AppConstants.warningOrange : AppConstants.successGreen).withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '₹${total.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    if (!isPending) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.receipt, color: AppConstants.tealPrimary),
                        onPressed: () => _viewBill(bill),
                        tooltip: 'View Bill',
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Details row
            Wrap(
              spacing: 20,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.table_restaurant, size: 16, color: AppConstants.tealPrimary),
                    const SizedBox(width: 4),
                    Text(tableNumbers, style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w500)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, size: 16, color: AppConstants.tealPrimary),
                    const SizedBox(width: 4),
                    Text(waiterNames, style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w500)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt, size: 16, color: AppConstants.tealPrimary),
                    const SizedBox(width: 4),
                    Text('$itemCount item${itemCount != 1 ? 's' : ''}', style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w500)),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.payment, size: 16, color: AppConstants.tealPrimary),
                    const SizedBox(width: 4),
                    Text(paymentMethod, style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            // Action buttons for pending bills only
            if (isPending)
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
                  _buildActionButton(
                    label: 'Add',
                    icon: Icons.add,
                    color: AppConstants.successGreen,
                    onPressed: () => _addProductToBill(bill),
                  ),
                  const SizedBox(width: 8),
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
        minimumSize: const Size(70, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
      ),
    );
  }

  void _viewBill(Map<String, dynamic> bill) {
    showDialog(
      context: context,
      builder: (ctx) => BillViewDialog(bill: bill),
    );
  }

  void _editBill(Map<String, dynamic> bill) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillEditPage(bill: bill),
      ),
    );
    if (result == true) {
      _fetchBills();
    }
  }
}