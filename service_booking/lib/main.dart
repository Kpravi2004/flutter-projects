import 'package:flutter/material.dart';
import 'ui/main_screen.dart';

void main() {
  runApp(const HomeFixApp());
}

class HomeFixApp extends StatefulWidget {
  const HomeFixApp({super.key});

  @override
  State<HomeFixApp> createState() => _HomeFixAppState();
}

class _HomeFixAppState extends State<HomeFixApp> {
  bool isDarkMode = false;

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),

      home: MainScreen(
        isDarkMode: isDarkMode,
        onThemeChanged: toggleTheme,
      ),
    );
  }
}
