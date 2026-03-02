import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {

  final String name;
  final String email;
  final String phone;
  final String address;

  const ProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
    phoneController = TextEditingController(text: widget.phone);
    addressController = TextEditingController(text: widget.address);
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("My Profile"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width * 0.06),
          child: Column(
            children: [

              // ===== Profile Image =====

              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: width * 0.18,
                    backgroundImage:
                    const AssetImage("assets/images/electrician.jpg"),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  )
                ],
              ),

              SizedBox(height: width * 0.08),

              // ===== Profile Form Card =====

              Container(
                padding: EdgeInsets.all(width * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [

                    buildField(
                        "Full Name",
                        nameController,
                        Icons.person,
                        width),

                    buildField(
                        "Email",
                        emailController,
                        Icons.email,
                        width),

                    buildField(
                        "Phone",
                        phoneController,
                        Icons.phone,
                        width),

                    buildField(
                        "Address",
                        addressController,
                        Icons.location_on,
                        width),
                  ],
                ),
              ),

              SizedBox(height: width * 0.1),

              // ===== Save Button =====

              SizedBox(
                width: double.infinity,
                height: width * 0.14,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {

                    Navigator.pop(context, {
                      "name": nameController.text,
                      "email": emailController.text,
                      "phone": phoneController.text,
                      "address": addressController.text,
                    });

                  },
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(
      String label,
      TextEditingController controller,
      IconData icon,
      double width) {

    return Padding(
      padding: EdgeInsets.only(bottom: width * 0.05),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue),
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
