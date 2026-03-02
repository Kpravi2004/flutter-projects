import 'package:flutter/material.dart';
import '../../models/service_model.dart';

class ServiceDetailPage extends StatelessWidget {

  final ServiceModel service;

  const ServiceDetailPage({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text(service.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(service.image),
            ),

            const SizedBox(height: 20),

            Text(
              service.description,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Book Now"),
            )

          ],
        ),
      ),
    );
  }
}
