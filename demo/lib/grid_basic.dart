import 'package:flutter/material.dart';
class GridBasicPage extends StatelessWidget {
  const GridBasicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Basic GridView"),
        backgroundColor: Colors.blue,
      ),

      body: GridView.count(
        crossAxisCount: 5,
        padding: const EdgeInsets.all(26),
        crossAxisSpacing: 15,
        mainAxisSpacing: 32,

        children: List.generate(10, (index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                "Item ${index + 1}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}