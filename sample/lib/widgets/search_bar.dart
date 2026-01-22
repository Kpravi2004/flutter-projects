import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final Function(String) onChanged;
  const SearchBox({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 450,
      child: TextField(
        onChanged:onChanged,
        decoration: InputDecoration(
          hintText: "Search by name, email or phone...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
