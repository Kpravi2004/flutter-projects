import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/custom_button.dart';

class BookingConfirmedPage extends StatelessWidget {
  final Map booking;

  const BookingConfirmedPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle,
                color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text(
              "Booking Confirmed!",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CustomButton(
              title: "Back to Home",
              onTap: () {
                context.go("/home");
              },
            )
          ],
        ),
      ),
    );
  }
}
