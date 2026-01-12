import 'package:flutter/material.dart';
class UserDirectoryPro extends StatefulWidget {
  const UserDirectoryPro({super.key});

  @override
  State<UserDirectoryPro> createState() => _UserDirectoryProState();
}

class _UserDirectoryProState extends State<UserDirectoryPro> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, String>> users = [];
  List<Map<String, String>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    filteredUsers = users;
  }

  void addUser() {
    String name = nameController.text.trim();
    String mobile = mobileController.text.trim();

    if (name.isEmpty || mobile.isEmpty) return;

    setState(() {
      users.add({"name": name, "mobile": mobile});
      filteredUsers = users;
    });

    nameController.clear();
    mobileController.clear();
  }

  void deleteUser(int index) {
    setState(() {
      users.removeAt(index);
      filteredUsers = users;
    });
  }

  void filterUsers(String query) {
    setState(() {
      filteredUsers = users
          .where((user) =>
      user["name"]!.toLowerCase().contains(query.toLowerCase()) ||
          user["mobile"]!.contains(query))
          .toList();
    });
  }

  void editUser(int index) {
    nameController.text = filteredUsers[index]["name"]!;
    mobileController.text = filteredUsers[index]["mobile"]!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit User"),
        content: const Text("Press update to save changes"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                filteredUsers[index]["name"] = nameController.text;
                filteredUsers[index]["mobile"] = mobileController.text;
              });
              nameController.clear();
              mobileController.clear();
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: const Text("User Directory Pro")),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: filterUsers,
                  decoration: const InputDecoration(
                    labelText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

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
                    onPressed: addUser,
                    child: const Text("Add User"),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(filteredUsers[index]["mobile"]!),
                  onDismissed: (direction) => deleteUser(index),
                  background: Container(color: Colors.red),
                  child: Card(
                    child: ListTile(
                      title: Text(filteredUsers[index]["name"]!),
                      subtitle: Text(filteredUsers[index]["mobile"]!),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => editUser(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteUser(index),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
