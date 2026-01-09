import 'package:flutter/material.dart';
import './widgets/dashboard_card.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Hotel Dashboard"),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Welcome back 👋",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Here is your hotel overview",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: const [
                  DashboardCard(
                    title: "Rooms",
                    value: "48",
                    icon: Icons.bed,
                    color: Colors.blue,
                  ),
                  DashboardCard(
                    title: "Bookings",
                    value: "12",
                    icon: Icons.calendar_today,
                    color: Colors.green,
                  ),
                  DashboardCard(
                    title: "Guests",
                    value: "86",
                    icon: Icons.people,
                    color: Colors.orange,
                  ),
                  DashboardCard(
                    title: "Revenue",
                    value: "₹82,500",
                    icon: Icons.attach_money,
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
