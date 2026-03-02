import 'package:flutter/material.dart';

class SubServicePage extends StatelessWidget {
  final String title;

  const SubServicePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {

    List<String> services = [];

    if (title == "Electrician") {
      services = [
        "Wiring Installation",
        "Switch Repair",
        "Fan Installation",
        "Light Installation",
        "MCB Replacement",
        "Inverter Setup",
        "Short Circuit Fix",
        "Power Backup Setup",
      ];
    } else if (title == "Plumber") {
      services = [
        "Tap Repair",
        "Pipe Leakage Fix",
        "Bathroom Fittings",
        "Motor Installation",
        "Drain Block Fix",
        "Water Tank Cleaning",
        "Toilet Installation",
        "Shower Installation",
      ];
    } else {
      services = [
        "General Service",
        "Installation",
        "Repair",
        "Maintenance",
      ];
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.build),
              title: Text(services[index]),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text("Book"),
              ),
            ),
          );
        },
      ),
    );
  }
}
