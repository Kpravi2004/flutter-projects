import 'package:flutter/material.dart';
import 'sub_service_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔵 TOP BLUE HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Hi Machi 👋",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Book trusted home services easily",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// 🔎 SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
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
          ),

          const SizedBox(height: 25),

          /// 🔥 SERVICE GRID (2x2)
          /// 🔥 SERVICE GRID (2x2 Realistic Services)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              children: const [

                ServiceCard(
                  title: "Home Wiring",
                  imageUrl:"assets/images/wiring.png",
                ),

                ServiceCard(
                  title: "Pipe Installation",
                  imageUrl: "assets/images/pipe_installation.png",
                ),

                ServiceCard(
                  title: "Appliance Repair",
                  imageUrl: "assets/images/appliance_service.png",
                ),

                ServiceCard(
                  title: "Pipe Leakage",
                  imageUrl: "assets/images/drain_cleaning.png",
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          /// 🎁 OFFER BANNER
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_offer,
                    color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Get 20% OFF on Plumbing Services!",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class ServiceCard extends StatefulWidget {
  final String title;
  final String imageUrl;

  const ServiceCard({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {

  double scale = 1.0;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTapDown: (_) => setState(() => scale = 0.96),
      onTapCancel: () => setState(() => scale = 1.0),
      onTapUp: (_) {
        setState(() => scale = 1.0);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                SubServicePage(title: widget.title),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(scale),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(widget.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.transparent
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(12),
          child: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
