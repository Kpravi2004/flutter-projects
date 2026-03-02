import 'package:flutter/material.dart';

class ConfirmationPage extends StatelessWidget {

  final VoidCallback onBackHome;

  const ConfirmationPage({
    super.key,
    required this.onBackHome,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [

          const Icon(Icons.hourglass_top,
              size: 80, color: Colors.orange),

          const SizedBox(height: 20),

          const Text(
            "Waiting for Confirmation...",
            style: TextStyle(fontSize: 18),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: onBackHome,
            child: const Text("Back to Home"),
          )
        ],
      ),
    );
  }
}
