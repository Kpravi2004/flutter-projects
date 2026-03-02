import 'package:flutter/material.dart';

class BookingStatusPage extends StatelessWidget {
  final String workerName;

  const BookingStatusPage({
    super.key,
    required this.workerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: const Text("Booking Status")),
      body: Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_top,
                size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              "Waiting for confirmation",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              "Worker: $workerName",
            ),
          ],
        ),
      ),
    );
  }
}
