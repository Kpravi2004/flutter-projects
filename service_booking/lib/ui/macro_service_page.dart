import 'package:flutter/material.dart';
import 'booking_details_page.dart';

class MacroServicePage extends StatefulWidget {
  final String category;

  const MacroServicePage({
    super.key,
    required this.category,
  });

  @override
  State<MacroServicePage> createState() =>
      _MacroServicePageState();
}

class _MacroServicePageState
    extends State<MacroServicePage> {

  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {

    final services = _getServices(widget.category);

    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(14),
                      border: Border.all(
                        color: selectedIndex == index
                            ? Colors.blue
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [

                        ClipRRect(
                          borderRadius:
                          const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                          child: Image.asset(
                            service["image"],
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        Padding(
                          padding:
                          const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                            children: [
                              Text(
                                service["title"],
                                style: const TextStyle(
                                    fontWeight:
                                    FontWeight.bold),
                              ),
                              Radio(
                                value: index,
                                groupValue:
                                selectedIndex,
                                onChanged: (value) {
                                  setState(() {
                                    selectedIndex =
                                    value!;
                                  });
                                },
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// SUBMIT BUTTON
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: selectedIndex == -1
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BookingDetailsPage(
                          serviceName:
                          services[selectedIndex]
                          ["title"],
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize:
                const Size(double.infinity, 50),
              ),
              child: const Text("Continue"),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getServices(
      String category) {

    if (category == "Electrical") {
      return [
        {
          "title": "Home Wiring",
          "image":
          "assets/images/wiring.jpg"
        },
        {
          "title": "Switch Installation",
          "image":
          "assets/images/wiring.jpg"
        },
      ];
    } else if (category == "Plumbing") {
      return [
        {
          "title": "Pipe Installation",
          "image":
          "assets/images/pipe.jpg"
        },
        {
          "title": "Pipe Leakage Fix",
          "image":
          "assets/images/leakage.jpg"
        },
      ];
    } else {
      return [
        {
          "title": "Appliance Repair",
          "image":
          "assets/images/appliance.jpg"
        },
      ];
    }
  }
}
