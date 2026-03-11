import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _bills = [];
  bool _isLoading = false;
  final Map<String, int> _productTotals = {};

  @override
  void initState() {
    super.initState();
    _fetchBills();
  }

  Future<void> _fetchBills() async {
    setState(() => _isLoading = true);
    try {
      String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      List<dynamic> bills = await ApiService.fetchBillsByDate(dateStr);
      setState(() {
        _bills = bills;
        _calculateTotals();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading orders: $e'), backgroundColor: AppConstants.errorRed),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateTotals() {
    _productTotals.clear();
    for (var bill in _bills) {
      for (var item in bill['items']) {
        String productName = item['productName'];
        int qty = item['quantity'];
        _productTotals[productName] = (_productTotals[productName] ?? 0) + qty;
      }
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _fetchBills();
    }
  }

  double get _totalRevenue {
    return _bills.fold(0.0, (sum, bill) => sum + (bill['totalAmount'] as num).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.lightBackground,
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: AppConstants.tealPrimary,
        actions: [
          // Date selector with icon and current date
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(_selectedDate),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_drop_down),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bills.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No orders for this date',
              style: TextStyle(color: AppConstants.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.calendar_today),
              label: const Text('Select Another Date'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.tealPrimary,
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppConstants.tealPrimary, AppConstants.tealDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.tealPrimary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        _bills.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Orders',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 40, color: Colors.white30),
                  Column(
                    children: [
                      Text(
                        '₹${_totalRevenue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Revenue',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Product summary
            if (_productTotals.isNotEmpty) ...[
              const Text(
                'Product Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppConstants.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppConstants.tealPrimary.withOpacity(0.3)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Product',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.tealPrimary,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Quantity',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.tealPrimary,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Rows
                    ..._productTotals.entries.map((entry) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                entry.key,
                                style: const TextStyle(color: AppConstants.textPrimary),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                entry.value.toString(),
                                style: const TextStyle(
                                  color: AppConstants.tealPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Orders list
            const Text(
              'Order Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ..._bills.map((bill) {
              final dateTime = DateTime.parse(bill['dateTime']);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: AppConstants.tealLight,
                    child: Text(
                      bill['id'].toString(),
                      style: TextStyle(color: AppConstants.tealPrimary),
                    ),
                  ),
                  title: Text(
                    'Bill #${bill['id']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.table_restaurant, size: 14, color: AppConstants.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            bill['tableNumbers'] ?? 'N/A',
                            style: TextStyle(color: AppConstants.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.person, size: 14, color: AppConstants.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            bill['waiterNames'] ?? 'N/A',
                            style: TextStyle(color: AppConstants.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${DateFormat('hh:mm a').format(dateTime)} • ₹${bill['totalAmount'].toStringAsFixed(2)}',
                        style: TextStyle(color: AppConstants.tealPrimary, fontSize: 12),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: (bill['items'] as List).map<Widget>((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item['productName']} x${item['quantity']}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                Text(
                                  '₹${(item['unitPrice'] * item['quantity']).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: AppConstants.tealPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}