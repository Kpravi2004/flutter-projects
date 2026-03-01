import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/models/service_model.dart';
import '../widgets/worker_card.dart';

class SelectWorkerPage extends StatelessWidget {
  final ServiceModel service;

  const SelectWorkerPage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final workers = ["Rahul Kumar", "Amit Sharma", "Suresh R"];

    return Scaffold(
      appBar: AppBar(title: const Text("Select Worker")),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: workers.length,
        itemBuilder: (context, index) {
          return WorkerCard(
            name: workers[index],
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime(2026),
                initialDate: DateTime.now(),
              );

              if (pickedDate == null) return;

              String? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              ).then((value) => value?.format(context));

              if (pickedTime == null) return;

              final booking = {
                "service": service,
                "worker": workers[index],
                "date": pickedDate,
                "time": pickedTime,
              };

              context.go("/booking-summary", extra: booking);
            },
          );
        },
      ),
    );
  }
}
