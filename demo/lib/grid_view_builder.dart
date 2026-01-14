import 'package:flutter/material.dart';
class GridExtentPage extends StatelessWidget {
  const GridExtentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GridView.extent"),
        backgroundColor: Colors.indigo,
      ),

      body: GridView.extent(
        padding: const EdgeInsets.all(16),

        maxCrossAxisExtent: 80,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,

        children: List.generate(12, (index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(12),
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
