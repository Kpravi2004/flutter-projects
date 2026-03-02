import 'package:flutter/material.dart';
import 'macro_service_page.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔎 SEARCH BAR
          TextField(
            decoration: InputDecoration(
              hintText: "Search services...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 30),

          /// 🔹 SERVICE CATEGORIES
          const Text(
            "Service Categories",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [

                CategoryBox(
                  title: "Electrical",
                  imagePath: "assets/images/electrical.jpg",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const MacroServicePage(category: "Electrical"),
                      ),
                    );
                  },
                ),

                CategoryBox(
                  title: "Plumbing",
                  imagePath: "assets/images/plumbing.jpg",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const MacroServicePage(category: "Plumbing"),
                      ),
                    );
                  },
                ),

                CategoryBox(
                  title: "Appliance Repair",
                  imagePath: "assets/images/appliance.jpg",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const MacroServicePage(category: "Appliance"),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          /// ⭐ TOP PROFESSIONALS
          const Text(
            "Top Professionals",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          const ProfessionalCard(
            name: "Ravi Electrical",
            profession: "Electrician",
            rating: 4.8,
            imagePath: "assets/images/worker1.jpg",
          ),

          const SizedBox(height: 14),

          const ProfessionalCard(
            name: "Kumar Plumbing",
            profession: "Plumber",
            rating: 4.7,
            imagePath: "assets/images/worker2.jpg",
          ),
        ],
      ),
    );
  }
}
class ProfessionalCard extends StatelessWidget {
  final String name;
  final String profession;
  final double rating;
  final String imagePath;

  const ProfessionalCard({
    super.key,
    required this.name,
    required this.profession,
    required this.rating,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage(imagePath),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  profession,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey),
                ),
                Row(
                  children: [
                    const Icon(Icons.star,
                        color: Colors.amber,
                        size: 16),
                    const SizedBox(width: 4),
                    Text(rating.toString()),
                  ],
                )
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text("View"),
          )
        ],
      ),
    );
  }
}
