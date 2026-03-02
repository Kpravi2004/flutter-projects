import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
                top: 60, left: 20, right: 20, bottom: 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 35, color: Colors.blue),
                ),
                SizedBox(height: 12),
                Text(
                  "Machi",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "machi@email.com",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          drawerItem(Icons.home_outlined, "Home"),
          drawerItem(Icons.calendar_today_outlined, "My Bookings"),
          drawerItem(Icons.payment_outlined, "Payments"),
          drawerItem(Icons.star_border, "Reviews"),
          drawerItem(Icons.settings_outlined, "Settings"),
          drawerItem(Icons.support_agent_outlined, "Support"),

          const Spacer(),
          const Divider(),
          drawerItem(Icons.logout, "Logout", isLogout: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget drawerItem(IconData icon, String title, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon,
          color: isLogout ? Colors.red : Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red : Colors.black87,
        ),
      ),
      onTap: () {},
    );
  }
}
