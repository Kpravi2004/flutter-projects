import 'package:flutter/material.dart';

class BookingDetailPage extends StatefulWidget {

  final String homeAddress;
  final Function() onSubmit;

  const BookingDetailPage({
    super.key,
    required this.homeAddress,
    required this.onSubmit,
  });

  @override
  State<BookingDetailPage> createState() =>
      _BookingDetailPageState();
}

class _BookingDetailPageState
    extends State<BookingDetailPage> {

  bool useHome = false;

  final doorController =
  TextEditingController();
  final areaController =
  TextEditingController();
  final districtController =
  TextEditingController();
  final stateController =
  TextEditingController();
  final pincodeController =
  TextEditingController();
  final descController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [

          CheckboxListTile(
            title:
            const Text("Use Home Address"),
            value: useHome,
            onChanged: (value) {
              setState(() {
                useHome = value!;
                if (useHome) {
                  areaController.text =
                      widget.homeAddress;
                }
              });
            },
          ),

          TextField(
              controller: doorController,
              decoration:
              const InputDecoration(
                  labelText:
                  "Door Number")),

          TextField(
              controller: areaController,
              decoration:
              const InputDecoration(
                  labelText:
                  "Area")),

          TextField(
              controller:
              districtController,
              decoration:
              const InputDecoration(
                  labelText:
                  "District")),

          TextField(
              controller:
              stateController,
              decoration:
              const InputDecoration(
                  labelText:
                  "State")),

          TextField(
              controller:
              pincodeController,
              decoration:
              const InputDecoration(
                  labelText:
                  "Pincode")),

          const SizedBox(height: 10),

          TextField(
            controller: descController,
            maxLines: 4,
            decoration:
            const InputDecoration(
                labelText:
                "Describe Issue"),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: widget.onSubmit,
            child: const Text("Submit"),
          )
        ],
      ),
    );
  }
}
