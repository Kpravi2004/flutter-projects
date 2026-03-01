import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/custom_button.dart';

class BookingSummaryPage extends StatelessWidget {
  final Map booking;

  const BookingSummaryPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final service = booking["service"];

    return Scaffold(
      appBar: AppBar(title: const Text("Booking Summary")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Service: ${service.title}"),
            Text("Worker: ${booking["worker"]}"),
            Text("Date: ${booking["date"].toString().split(' ')[0]}"),
            Text("Time: ${booking["time"]}"),
            const Spacer(),
            CustomButton(
              title: "Confirm Booking",
              onTap: () {
                context.go("/booking-confirmed", extra: booking);
              },
            )
          ],
        ),
      ),
    );
  }
}
