class User {
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool active;

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.active = true,
  });
}
