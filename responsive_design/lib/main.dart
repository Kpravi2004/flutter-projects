import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'expense_state.dart';
import 'expense_list_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ExpenseState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExpenseListPage(),
    );
  }
}
