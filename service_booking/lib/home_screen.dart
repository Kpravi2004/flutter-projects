import 'package:flutter/material.dart';
import 'home_desktop.dart';
import 'home_mobile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return width > 650
        ? const HomeDesktop()
        : const HomeMobile();
  }
}
