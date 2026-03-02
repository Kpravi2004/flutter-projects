import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isUser = true;

  final _emailOrPhone = TextEditingController();
  final _password = TextEditingController();

  Future<void> _login() async {
    if (_emailOrPhone.text.isEmpty || _password.text.isEmpty) {
      _showError("All fields are required");
      return;
    }

    final url = Uri.parse('http://localhost:8080/api/auth/login');

    final payload = {
      "role": isUser ? "user" : "worker",
      "emailOrPhone": _emailOrPhone.text.trim(),
      "password": _password.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        // ✅ Login success
        // Navigator.pushReplacementNamed(context, '/home');
        print("Login success");
      } else {
        _showError(data["message"]);
      }
    } catch (e) {
      _showError("Unable to connect to server");
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Login to continue',
                      style: TextStyle(color: Colors.black54)),

                  const SizedBox(height: 26),

                  _RoleSelector(
                    isUser: isUser,
                    onChanged: (v) => setState(() => isUser = v),
                  ),

                  const SizedBox(height: 24),

                  _InputField(
                    controller: _emailOrPhone,
                    label: 'Email or Phone',
                    icon: Icons.person,
                  ),
                  _InputField(
                    controller: _password,
                    label: 'Password',
                    icon: Icons.lock,
                    isPassword: true,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        isUser ? 'Login as User' : 'Login as Worker',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                      child: const Text(
                        "Don't have an account? Register",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------- COMMON WIDGETS ---------- */

class _RoleSelector extends StatelessWidget {
  final bool isUser;
  final Function(bool) onChanged;

  const _RoleSelector({
    required this.isUser,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _RoleButton(
            label: 'User',
            selected: isUser,
            onTap: () => onChanged(true),
          ),
          _RoleButton(
            label: 'Worker',
            selected: !isUser,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;

  const _InputField({
    required this.label,
    required this.icon,
    required this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF7F9FC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
