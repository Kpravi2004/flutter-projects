import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'user_actions.dart';

class UsersTable extends StatelessWidget {
  final List<User> users;
  final Function(int) onDelete;
  final Function(int) onEdit;

  const UsersTable({
    super.key,
    required this.users,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 8),
            ],
          ),
          child: users.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text("No users added")),
          )
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Email")),
                DataColumn(label: Text("Phone")),
                DataColumn(label: Text("Role")),
                DataColumn(label: Text("Active")),
                DataColumn(label: Text("Actions")),
              ],
              rows: List.generate(users.length, (index) {
                final u = users[index];
                return DataRow(cells: [
                  DataCell(Text(u.name)),
                  DataCell(Text(u.email)),
                  DataCell(Text(u.phone)),
                  DataCell(Chip(label: Text(u.role))),
                  const DataCell(
                    Text("Yes", style: TextStyle(color: Colors.green)),
                  ),
                  DataCell(
                    UserActions(
                      onEdit: () => onEdit(index),
                      onDelete: () => onDelete(index),
                    ),
                  ),
                ]);
              }),
            ),
          ),
        ),
      ),
    );
  }
}
