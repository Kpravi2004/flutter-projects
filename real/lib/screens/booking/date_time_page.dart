import 'package:flutter/material.dart';

class DateTimePage extends StatefulWidget {

  final Function(Map<String, dynamic>)
  onWorkerSubmit;

  const DateTimePage({
    super.key,
    required this.onWorkerSubmit,
  });

  @override
  State<DateTimePage> createState() =>
      _DateTimePageState();
}

class _DateTimePageState
    extends State<DateTimePage> {

  DateTime? date;
  TimeOfDay? time;
  bool showWorkers = false;
  int? selectedWorkerIndex;

  List<Map<String, dynamic>> workers = [
    {"name": "Suresh", "rating": 4.9},
    {"name": "Mani", "rating": 4.7},
  ];

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [

          const Text(
            "Schedule Service",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          ListTile(
            title: Text(
                date == null
                    ? "Select Date"
                    : date.toString()),
            onTap: () async {
              final picked =
              await showDatePicker(
                context: context,
                initialDate:
                DateTime.now(),
                firstDate:
                DateTime.now(),
                lastDate:
                DateTime(2030),
              );
              if (picked != null) {
                setState(() =>
                date = picked);
              }
            },
          ),

          ListTile(
            title: Text(
                time == null
                    ? "Select Time"
                    : time!
                    .format(context)),
            onTap: () async {
              final picked =
              await showTimePicker(
                context: context,
                initialTime:
                TimeOfDay.now(),
              );
              if (picked != null) {
                setState(() =>
                time = picked);
              }
            },
          ),

          const SizedBox(height: 10),

          ElevatedButton(
            onPressed:
            (date != null &&
                time != null)
                ? () {
              setState(() =>
              showWorkers =
              true);
            }
                : null,
            child: const Text(
                "See Available Workers"),
          ),

          if (showWorkers) ...[

            const SizedBox(height: 20),

            const Text(
              "Available Workers",
              style: TextStyle(
                  fontWeight:
                  FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ...workers.asMap().entries.map(
                    (entry) {

                  int index =
                      entry.key;
                  var worker =
                      entry.value;

                  bool isSelected =
                      selectedWorkerIndex ==
                          index;

                  return Card(
                    child: ListTile(
                      leading:
                      const CircleAvatar(
                        child: Icon(
                            Icons
                                .person),
                      ),
                      title: Text(
                          worker[
                          "name"]),
                      subtitle: Text(
                          "⭐ ${worker["rating"]}"),
                      trailing:
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          isSelected
                              ? Colors
                              .green
                              : Colors
                              .blue,
                        ),
                        onPressed:
                            () {
                          setState(() {
                            selectedWorkerIndex =
                                index;
                          });
                        },
                        child: Text(
                            isSelected
                                ? "Selected"
                                : "Select"),
                      ),
                    ),
                  );
                }),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed:
              selectedWorkerIndex ==
                  null
                  ? null
                  : () {
                widget.onWorkerSubmit(
                    workers[
                    selectedWorkerIndex!]);
              },
              child:
              const Text("Submit"),
            )
          ]
        ],
      ),
    );
  }
}
