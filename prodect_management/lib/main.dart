import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'screens/product_management_page.dart';
import 'screens/order_page.dart';
import 'utils/app_colors.dart';
import 'widgets/current_time_bar.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductProvider()..loadProducts(),
      child: MaterialApp(
        title: 'Restaurant Manager',
        theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: AppColors.background,
          primaryColor: AppColors.primaryPink,
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryPink,
            secondary: AppColors.primaryPink,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primaryPink,
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              foregroundColor: Colors.white,
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryPink,
            ),
          ),
        ),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: Column(
          children: [
            const CurrentTimeBar(),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: const [
                  ProductManagementPage(),
                  OrderPage(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primaryPink,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Order',
          ),
        ],
      ),
    );
  }
}