import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../widgets/header.dart';
import '../widgets/search_bar.dart';
import '../widgets/users_table.dart';
import '../widgets/add_user.dart';
import '../widgets/edit_user_data.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final List<User> users = [];
  List<User> filteredUsers =[];
  @override
  void initState() {
    super.initState();
    filteredUsers = List.from(users);
  }
  void openAddUserDialog() {
    showDialog(
      context: context,
      builder: (_) => AddUserDialog(
        onAdd: (user) {
          setState(() {
            users.add(user);
            filteredUsers =List.from(users);
          });
        },
      ),
    );
  }

  void openEditUserDialog(int index) {
    showDialog(
      context: context,
      builder: (_) => EditUserDialog(
        user: users[index],
        onSave: (updatedUser) {
          setState(() {
            users[index] = updatedUser;
            filteredUsers =List.from(users);
          });
        },
      ),
    );
  }

  void deleteUser(int index) {
    setState(() {
      users.removeAt(index);
      filteredUsers =List.from(users);
    });
  }
  void onSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredUsers = List.from(users);
      });
      return;
    }

    setState(() {
      filteredUsers = users.where((user) {
        return user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.email.toLowerCase().contains(query.toLowerCase()) ||
            user.phone.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(
                onAddUser: openAddUserDialog,
              ),

              const SizedBox(height: 20),

              SearchBox(
                onChanged: onSearch,
              ),

              const SizedBox(height: 20),
              UsersTable(
                users: filteredUsers,
                onDelete: deleteUser,
                onEdit: openEditUserDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
