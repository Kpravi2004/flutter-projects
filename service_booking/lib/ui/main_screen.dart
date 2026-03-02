import 'package:flutter/material.dart';
import 'home_page.dart';
import 'explore_page.dart';
import 'bookings_page.dart';
import 'messages_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const MainScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const ExplorePage(),
      const BookingsPage(),
      const MessagesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("HomeFix"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          Row(
            children: [
              const Icon(Icons.light_mode, size: 18),
              Switch(
                value: widget.isDarkMode,
                onChanged: widget.onThemeChanged,
              ),
              const Icon(Icons.dark_mode, size: 18),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),

      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 60, bottom: 20, left: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        size: 30, color: Colors.blue),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Machi",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "machi@email.com",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            _drawerItem(Icons.home, "Home", 0),
            _drawerItem(Icons.calendar_today, "My Bookings", 2),
            _drawerItem(Icons.payment, "Payments", -1),
            _drawerItem(Icons.star, "Reviews", -1),
            _drawerItem(Icons.person, "Profile", 4),
            _drawerItem(Icons.settings, "Settings", -1),
            _drawerItem(Icons.support_agent, "Support", -1),

            const Spacer(),
            const Divider(),
            _drawerItem(Icons.logout, "Logout", -1,
                isLogout: true),
            const SizedBox(height: 20),
          ],
        ),
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.search), label: "Explore"),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: "Bookings"),
          NavigationDestination(icon: Icon(Icons.chat), label: "Messages"),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _drawerItem(
      IconData icon, String title, int pageIndex,
      {bool isLogout = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red : null,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        if (pageIndex >= 0) {
          setState(() {
            _currentIndex = pageIndex;
          });
        }
      },
    );
  }
}
