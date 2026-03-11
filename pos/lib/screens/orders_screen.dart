import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Orders"),
        backgroundColor: Colors.teal,
      ),

      body: const Center(
        child: Text(
          "Orders Page",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}