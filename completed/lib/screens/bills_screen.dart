import 'package:flutter/material.dart';
import '../utils/constants.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.lightBackground,
      appBar: AppBar(
        title: const Text('Bills'),
        backgroundColor: AppConstants.tealPrimary,
      ),
      body: const Center(
        child: Text('Bills screen coming soon'),
      ),
    );
  }
}