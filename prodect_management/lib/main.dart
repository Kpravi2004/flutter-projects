// lib/main.dart

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
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: AppConstants.lightBackground,
          primaryColor: AppConstants.tealPrimary,
          colorScheme: const ColorScheme.light(
            primary: AppConstants.tealPrimary,
            secondary: AppConstants.coralAccent,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppConstants.lightSurface,
            foregroundColor: AppConstants.textPrimary,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: AppConstants.textPrimary,
              fontSize: AppConstants.fontSizeLg,
              fontWeight: AppConstants.fontWeightSemiBold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.tealPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.tealPrimary,
            ),
          ),
        ),
        home: const MainScreen(),
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
        backgroundColor: AppConstants.lightSurface,
        selectedItemColor: AppConstants.tealPrimary,
        unselectedItemColor: AppConstants.textSecondary,
        selectedLabelStyle: TextStyle(
          fontWeight: AppConstants.fontWeightMedium,
          fontSize: AppConstants.fontSizeXs,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: AppConstants.fontWeightNormal,
          fontSize: AppConstants.fontSizeXs,
        ),
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