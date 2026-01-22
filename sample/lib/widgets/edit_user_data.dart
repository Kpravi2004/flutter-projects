import 'package:flutter/material.dart';
import '../models/user_model.dart';

class EditUserDialog extends StatefulWidget {
  final User user;
  final Function(User) onSave;

  const EditUserDialog({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late String role;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.user.name);
    emailCtrl = TextEditingController(text: widget.user.email);
    phoneCtrl = TextEditingController(text: widget.user.phone);
    role = widget.user.role;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit User"),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone")),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: role,
              decoration: const InputDecoration(labelText: "Role"),
              items: const [
                DropdownMenuItem(value: "Admin", child: Text("Admin")),
                DropdownMenuItem(value: "Staff", child: Text("Staff")),
              ],
              onChanged: (v) => role = v!,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(
              User(
                name: nameCtrl.text,
                email: emailCtrl.text,
                phone: phoneCtrl.text,
                role: role,
              ),
            );
            Navigator.pop(context);
          },
          child: const Text("Update"),
        ),
      ],
    );
  }
}
