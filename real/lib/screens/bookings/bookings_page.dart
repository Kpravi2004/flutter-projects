import 'package:flutter/material.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [

          const TabBar(
            labelColor: Color(0xFF2563EB),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF2563EB),
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Confirmed"),
              Tab(text: "Completed"),
            ],
          ),

          Expanded(
            child: TabBarView(
              children: [

                buildPending(width),
                buildConfirmed(width),
                buildCompleted(width),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ================= PENDING =================

  Widget buildPending(double width) {
    return ListView(
      padding: EdgeInsets.all(width * 0.05),
      children: [

        bookingCard(
          title: "Electrician - Fan Repair",
          date: "18 Feb 2026",
          status: "Pending",
          color: Colors.orange,
        ),

        bookingCard(
          title: "Plumber - Pipe Leakage",
          date: "20 Feb 2026",
          status: "Pending",
          color: Colors.orange,
        ),
      ],
    );
  }

  // ================= CONFIRMED =================

  Widget buildConfirmed(double width) {
    return ListView(
      padding: EdgeInsets.all(width * 0.05),
      children: [

        bookingCard(
          title: "Switch Repair",
          date: "15 Feb 2026",
          status: "Confirmed",
          color: Colors.green,
        ),
      ],
    );
  }

  // ================= COMPLETED =================

  Widget buildCompleted(double width) {
    return ListView(
      padding: EdgeInsets.all(width * 0.05),
      children: [

        bookingCard(
          title: "House Wiring",
          date: "10 Feb 2026",
          status: "Completed",
          color: Colors.blue,
        ),

        bookingCard(
          title: "Tap Installation",
          date: "05 Feb 2026",
          status: "Completed",
          color: Colors.blue,
        ),
      ],
    );
  }

  // ================= BOOKING CARD =================

  Widget bookingCard({
    required String title,
    required String date,
    required String status,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [

          const CircleAvatar(
            backgroundColor: Color(0xFF2563EB),
            child: Icon(Icons.build, color: Colors.white),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(title,
                    style: const TextStyle(
                        fontWeight:
                        FontWeight.bold)),

                const SizedBox(height: 6),

                Text("Date: $date"),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
