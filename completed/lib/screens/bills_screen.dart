import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _fetchBills();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _fetchBills();
    }
  }

  Future<void> _fetchBills() async {
    setState(() => _isLoading = true);
    try {
      // Option 1: fetch all and filter (simpler)
      List<dynamic> allBills = await ApiService.fetchAllBills();
      setState(() {
        _pendingBills = allBills.where((b) => b['status'] == 'pending').toList();
        _completedBills = allBills.where((b) => b['status'] == 'completed').toList();
      });
      // Option 2: fetch by status using separate endpoints (more efficient)
      // _pendingBills = await ApiService.fetchBillsByStatus('pending');
      // _completedBills = await ApiService.fetchBillsByStatus('completed');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bills: $e'), backgroundColor: AppConstants.errorRed),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          _buildBillList(_pendingBills, isPending: true),
          _buildBillList(_completedBills, isPending: false),
        ],
      ),
    );
  }

  Widget _buildBillList(List<dynamic> bills, {required bool isPending}) {
    if (bills.isEmpty) {
      return Center(
        child: Text(
          'No ${isPending ? 'pending' : 'completed'} bills',
          style: TextStyle(color: AppConstants.textSecondary, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        final dateTime = DateTime.parse(bill['dateTime']);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPending ? AppConstants.warningOrange : AppConstants.successGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '₹${bill['totalAmount'].toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${bill['items'].length} item(s)',
                  style: TextStyle(color: AppConstants.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.visibility, color: AppConstants.tealPrimary),
                      onPressed: () => _viewBill(bill),
                    ),
                    if (isPending) ...[
                      IconButton(
                        icon: Icon(Icons.edit, color: AppConstants.coralAccent),
                        onPressed: () => _editBill(bill),
                      ),
                      IconButton(
                        icon: Icon(Icons.check_circle, color: AppConstants.successGreen),
                        onPressed: () => _confirmBill(bill),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _viewBill(Map<String, dynamic> bill) {
    showDialog(
      context: context,
      builder: (ctx) => BillViewDialog(bill: bill),
    );
  }

  void _editBill(Map<String, dynamic> bill) {
    // TODO: Implement bill edit page (similar to OrderPage but pre-filled)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feature coming soon')),
    );
  }

  void _confirmBill(Map<String, dynamic> bill) async {
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