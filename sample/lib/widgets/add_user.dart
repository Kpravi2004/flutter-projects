import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AddUserDialog extends StatefulWidget {
  final Function(User) onAdd;

  const AddUserDialog({super.key, required this.onAdd});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  String role = "Staff";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add User"),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone")),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: role,
              items: const [
                DropdownMenuItem(value: "Admin", child: Text("Admin")),
                DropdownMenuItem(value: "Staff", child: Text("Staff")),
              ],
              onChanged: (v) => role = v!,
              decoration: const InputDecoration(labelText: "Role"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            widget.onAdd(
              User(
                name: nameCtrl.text,
                email: emailCtrl.text,
                phone: phoneCtrl.text.isEmpty ? "-" : phoneCtrl.text,
                role: role,
              ),
            );
            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
