import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';
import '../../models/service_model.dart';

class CategoryServicesPage extends StatelessWidget {

  final String category;

  const CategoryServicesPage({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {

    List<ServiceModel> filtered =
    DummyData.services
        .where((s) => s.category == category)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (context, index) {

          final service = filtered[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: Image.asset(
                service.image,
                width: 60,
                fit: BoxFit.cover,
              ),
              title: Text(service.title),
              subtitle: Text(service.description),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text("Select"),
              ),
            ),
          );
        },
      ),
    );
  }
}
