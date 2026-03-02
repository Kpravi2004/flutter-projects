import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/custom_button.dart';
import '../models/service_model.dart';

class ServiceDetailsPage extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailsPage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(service.title)),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(service.image),
            const SizedBox(height: 20),
            Text(service.title,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(service.description),
            const SizedBox(height: 10),
            Text("₹${service.price}",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const Spacer(),
            CustomButton(
              title: "Book Now",
              onTap: () {
                // Next part booking
              },
            )
          ],
        ),
      ),
    );
  }
}
