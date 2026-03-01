import 'package:flutter/material.dart';
import 'worker_selection_page.dart';

class BookingDetailsPage extends StatefulWidget {
  final String serviceName;

  const BookingDetailsPage({
    super.key,
    required this.serviceName,
  });

  @override
  State<BookingDetailsPage> createState() =>
      _BookingDetailsPageState();
}

class _BookingDetailsPageState
    extends State<BookingDetailsPage> {

  final nameController = TextEditingController();
  final addressController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: Text(widget.serviceName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Your Name",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Address",
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        WorkerSelectionPage(
                          serviceName:
                          widget.serviceName,
                          userName:
                          nameController.text,
                        ),
                  ),
                );
              },
              child:
              const Text("Find Workers"),
            )
          ],
        ),
      ),
    );
  }
}
