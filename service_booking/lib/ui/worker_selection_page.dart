import 'package:flutter/material.dart';
import 'booking_status_page.dart';

class WorkerSelectionPage extends StatefulWidget {
  final String serviceName;
  final String userName;

  const WorkerSelectionPage({
    super.key,
    required this.serviceName,
    required this.userName,
  });

  @override
  State<WorkerSelectionPage> createState() =>
      _WorkerSelectionPageState();
}

class _WorkerSelectionPageState
    extends State<WorkerSelectionPage> {

  int selectedIndex = -1;

  final workers = [
    "Ravi Kumar",
    "Arun Electrical",
    "Vijay Services",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text("Select Worker")),
      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              itemCount: workers.length,
              itemBuilder: (context, index) {
                return RadioListTile(
                  title: Text(workers[index]),
                  value: index,
                  groupValue: selectedIndex,
                  onChanged: (value) {
                    setState(() {
                      selectedIndex = value!;
                    });
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: selectedIndex == -1
                  ? null
                  : () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BookingStatusPage(
                          workerName:
                          workers[selectedIndex],
                        ),
                  ),
                );
              },
              child: const Text("Confirm Booking"),
            ),
          )
        ],
      ),
    );
  }
}
