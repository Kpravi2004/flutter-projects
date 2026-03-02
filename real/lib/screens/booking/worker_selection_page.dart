import 'package:flutter/material.dart';

class WorkerSelectionPage extends StatelessWidget {

  final Function(Map<String, dynamic>) onWorkerSelected;

  const WorkerSelectionPage({
    super.key,
    required this.onWorkerSelected,
  });

  @override
  Widget build(BuildContext context) {

    List<Map<String, dynamic>> workers = [
      {"name": "Suresh", "rating": 4.9, "distance": 1.2},
      {"name": "Mani", "rating": 4.7, "distance": 2.5},
      {"name": "Kumar", "rating": 4.5, "distance": 1.8},
    ];

    workers.sort((a, b) =>
        (b["rating"] as double)
            .compareTo(a["rating"] as double));

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: workers.length,
      itemBuilder: (context, index) {

        final worker = workers[index];

        return Card(
          margin:
          const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title:
            Text(worker["name"] as String),
            subtitle: Row(
              children: [
                const Icon(Icons.star,
                    color: Colors.orange,
                    size: 16),
                const SizedBox(width: 4),
                Text(
                    "${worker["rating"]} • ${worker["distance"]} km"),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: () =>
                  onWorkerSelected(worker),
              child: const Text("Select"),
            ),
          ),
        );
      },
    );
  }
}
