import 'package:flutter/material.dart';
import 'user_input_page.dart';
import 'contact_app.dart';
import 'user_directory.dart';
import 'user_directory_pro.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Start page
      initialRoute: '/',

      routes: {
        '/': (context) => const UserDirectoryPro(),
      },
    );
  }
}
