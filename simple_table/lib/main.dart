import 'package:flutter/material.dart';
import 'screens/mobile_table_screen.dart';
import 'screens/table_management_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SENTINIX Table Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ResponsiveTableScreen(),
    );
  }
}

class ResponsiveTableScreen extends StatelessWidget {
  const ResponsiveTableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 650) {
      return const MobileTableScreen();
    } else {
      return const TableManagementScreen();
    }
  }
}