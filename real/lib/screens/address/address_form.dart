import 'package:flutter/material.dart';

class AddressFormPage extends StatefulWidget {

  final String currentAddress;

  const AddressFormPage({
    super.key,
    required this.currentAddress,
  });

  @override
  State<AddressFormPage> createState() =>
      _AddressFormPageState();
}

class _AddressFormPageState
    extends State<AddressFormPage> {

  final _formKey = GlobalKey<FormState>();

  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    addressController =
        TextEditingController(
            text: widget.currentAddress);
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Update Address"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width * 0.06),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                Container(
                  padding: EdgeInsets.all(width * 0.06),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 10,
                        offset:
                        const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    children: [

                      buildField(
                        label: "Full Address",
                        controller:
                        addressController,
                        icon: Icons.home,
                      ),

                      SizedBox(
                          height: width * 0.06),

                      buildField(
                        label: "City",
                        icon:
                        Icons.location_city,
                      ),

                      SizedBox(
                          height: width * 0.06),

                      buildField(
                        label: "State",
                        icon:
                        Icons.map_outlined,
                      ),

                      SizedBox(
                          height: width * 0.06),

                      buildField(
                        label: "Pincode",
                        icon:
                        Icons.pin_drop,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: width * 0.1),

                SizedBox(
                  width: double.infinity,
                  height: width * 0.14,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF2563EB),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                            18),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey
                          .currentState!
                          .validate()) {

                        Navigator.pop(
                          context,
                          addressController.text,
                        );
                      }
                    },
                    child: const Text(
                      "Save Address",
                      style: TextStyle(
                          fontSize: 16),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildField({
    required String label,
    IconData? icon,
    TextEditingController? controller,
  }) {
    return TextFormField(
      controller: controller,
      validator: (value) =>
      value!.isEmpty
          ? "Required field"
          : null,
      decoration: InputDecoration(
        prefixIcon:
        Icon(icon, color: Colors.blue),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
