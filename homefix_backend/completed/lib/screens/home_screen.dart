import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'responsive_table_screen.dart';
import 'bills_screen.dart';
import 'product_management_page.dart';
import '../providers/product_provider.dart';
import '../utils/constants.dart';
import 'orders_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ResponsiveTableScreen(),  // first tab: table management
    BillsScreen(),            // second tab: bills placeholder
    ProductManagementPage(),
    OrdersScreen(),
    // third tab: product management
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.table_restaurant),
            label: 'Tables',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Bills',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood),
            label: 'Products',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Orders'),
        ],
        selectedItemColor: AppConstants.tealPrimary,
        unselectedItemColor: AppConstants.textSecondary,
        backgroundColor: AppConstants.lightSurface,
      ),
    );
  }
}