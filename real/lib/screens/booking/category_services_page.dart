import 'package:flutter/material.dart';

class CategoryServicesPage extends StatefulWidget {

  final String category;
  final Function(List<Map<String, dynamic>>) onSubmit;

  const CategoryServicesPage({
    super.key,
    required this.category,
    required this.onSubmit,
  });

  @override
  State<CategoryServicesPage> createState() =>
      _CategoryServicesPageState();
}

class _CategoryServicesPageState
    extends State<CategoryServicesPage> {

  List<Map<String, dynamic>> services = [
    {
      "title": "Fan Repair",
      "description": "Fix ceiling & table fans.",
      "image": "assets/images/fan_repair.jpg",
    },
    {
      "title": "Switch Repair",
      "description": "Fix switches safely.",
      "image":
      "assets/images/switch_socket_repair.jpg",
    },
  ];

  Set<int> selectedIndexes = {};

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [

          const Text(
            "Select Services",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {

                final service =
                services[index];

                bool isSelected =
                selectedIndexes
                    .contains(index);

                return Container(
                  margin:
                  const EdgeInsets.only(
                      bottom: 20),
                  decoration:
                  BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(
                        20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors
                            .grey.shade300,
                        blurRadius: 8,
                        offset:
                        const Offset(
                            0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [

                      ClipRRect(
                        borderRadius:
                        const BorderRadius
                            .vertical(
                            top: Radius
                                .circular(
                                20)),
                        child: Image.asset(
                          service["image"],
                          height: 160,
                          width: double
                              .infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      Padding(
                        padding:
                        const EdgeInsets
                            .all(16),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [

                            Text(
                                service[
                                "title"],
                                style: const TextStyle(
                                    fontSize:
                                    18,
                                    fontWeight:
                                    FontWeight
                                        .bold)),

                            const SizedBox(
                                height: 8),

                            Text(service[
                            "description"]),

                            const SizedBox(
                                height: 12),

                            SizedBox(
                              width: double
                                  .infinity,
                              child:
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  isSelected
                                      ? Colors.green
                                      : Colors
                                      .blue,
                                ),
                                onPressed:
                                    () {
                                  setState(
                                          () {
                                        if (isSelected) {
                                          selectedIndexes.remove(index);
                                        } else {
                                          selectedIndexes.add(index);
                                        }
                                      });
                                },
                                child: Text(
                                    isSelected
                                        ? "Selected"
                                        : "Select"),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
              selectedIndexes.isEmpty
                  ? null
                  : () {
                final selected =
                selectedIndexes
                    .map((i) =>
                services[i])
                    .toList();
                widget.onSubmit(
                    selected);
              },
              child: const Text("Submit"),
            ),
          ),
        ],
      ),
    );
  }
}
