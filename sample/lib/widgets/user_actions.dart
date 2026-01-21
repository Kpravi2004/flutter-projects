import 'package:flutter/material.dart';

class UserActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserActions({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) {
          if (value == 'edit') onEdit();
          if (value == 'delete') onDelete();
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text("Edit")),
          PopupMenuItem(value: 'delete', child: Text("Delete")),
        ],
      );
    }

    return Row(
      children: [
        IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, color: Colors.blue)),
        IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, color: Colors.red)),
      ],
    );
  }
}
