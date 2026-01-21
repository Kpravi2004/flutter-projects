import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final VoidCallback onAddUser;

  const Header({super.key, required this.onAddUser});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Users",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        ElevatedButton.icon(
          onPressed: onAddUser,
          icon: const Icon(Icons.add),
          label: const Text("Add User"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
