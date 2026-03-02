import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../models/service_model.dart';
import '../widgets/service_card.dart';

class ServiceListPage extends StatelessWidget {
  final String category;

  const ServiceListPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final services = _getDummyServices();

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: ListView.builder(
          itemCount: services.length,
          itemBuilder: (context, index) {
            return ServiceCard(service: services[index]);
          },
        ),
      ),
    );
  }

  List<ServiceModel> _getDummyServices() {
    return [
      ServiceModel(
        title: "Basic Repair",
        description: "General $category repair service",
        price: 499,
        rating: 4.5,
        image: "assets/images/micro_services/img_wiring.png",
      ),
      ServiceModel(
        title: "Advanced Installation",
        description: "Professional installation",
        price: 999,
        rating: 4.8,
        image: "assets/images/micro_services/img_fan_repair.png",
      ),
    ];
  }
}
