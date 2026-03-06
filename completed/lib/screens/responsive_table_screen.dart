import 'package:flutter/material.dart';
import 'mobile_table_screen.dart';
import 'table_management_screen.dart';

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