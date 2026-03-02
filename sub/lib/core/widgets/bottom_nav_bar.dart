import 'package:flutter/material.dart';
import '../../features/dashboard/screens/dashboard_page.dart';
import '../../features/profile/screens/profile_page.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 0;

  final screens = const [
    DashboardPage(),
    Center(child: Text("Explore")),
    Center(child: Text("Bookings")),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() => currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home"),
          NavigationDestination(icon: Icon(Icons.search), label: "Explore"),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: "Bookings"),
          NavigationDestination(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}
