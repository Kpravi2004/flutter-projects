import 'package:flutter/material.dart';
import 'home_desktop.dart';
import 'home_mobile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1000) {
      return const HomeDesktop();
    } else {
      return const HomeMobile();
    }
  }
}
