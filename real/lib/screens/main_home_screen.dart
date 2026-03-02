import 'package:flutter/material.dart';
import 'dashboard/user_dashboard.dart';
import 'profile/profile_page.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {

  int currentIndex = 0;

  String userName = "Ravi Kumar";
  String userEmail = "ravi@email.com";
  String userPhone = "9876543210";
  String userAddress = "Coimbatore, Tamil Nadu";

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      drawer: buildDrawer(width),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: IndexedStack(
        index: currentIndex,
        children: [

          UserDashboard(
            userAddress: userAddress,
            userName: userName,
          ),

          const Center(child: Text("Bookings Page")),

          const Center(child: Text("Chat Page")),

          ProfilePage(
            name: userName,
            email: userEmail,
            phone: userPhone,
            address: userAddress,
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.book), label: "Bookings"),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget buildDrawer(double width) {
    return Drawer(
      width: width * 0.80,
      child: Container(
        color: const Color(0xFF1E293B),
        child: SafeArea(
          child: Column(
            children: [

              SizedBox(height: width * 0.08),

              CircleAvatar(
                radius: width * 0.12,
                backgroundImage:
                const AssetImage("assets/images/electrician.jpg"),
              ),

              SizedBox(height: width * 0.04),

              const Text(
                "Ravi Kumar",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20),
              ),

              SizedBox(height: width * 0.08),

              drawerItem(Icons.person, "Profile"),
              drawerItem(Icons.book, "Bookings"),
              drawerItem(Icons.support, "Support"),
              drawerItem(Icons.logout, "Logout"),
            ],
          ),
        ),
      ),
    );
  }

  Widget drawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {},
    );
  }
}
