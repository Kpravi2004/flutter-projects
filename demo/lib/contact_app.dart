import 'package:flutter/material.dart';

class ContactApp extends StatefulWidget {
  const ContactApp({super.key});

  @override
  State<ContactApp> createState() => _ContactAppState();
}

class _ContactAppState extends State<ContactApp> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  final List<Map<String, String>> contacts = [];

  void addContact() {
    String name = nameController.text.trim();
    String mobile = mobileController.text.trim();

    if (name.isEmpty || mobile.isEmpty) return;

    setState(() {
      contacts.add({
        "name": name,
        "mobile": mobile,
      });
    });

    nameController.clear();
    mobileController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contact List")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Mobile",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: addContact,
                    child: const Text("Add Contact"),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          Expanded(
            child: ListView.separated(
              itemCount: contacts.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final contact = contacts[index];

                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(contact["name"]!),
                  subtitle: Text(contact["mobile"]!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
