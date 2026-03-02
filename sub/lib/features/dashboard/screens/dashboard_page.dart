import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../widgets/greeting_header.dart';
import '../widgets/search_bar.dart';
import '../widgets/promo_banner.dart';
import '../widgets/category_grid.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              GreetingHeader(),
              SizedBox(height: 25),
              SearchBarSection(),
              SizedBox(height: 30),
              PromoBanner(),
              SizedBox(height: 30),
              CategoryGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
