import 'package:flutter/material.dart';

class HomeMobile extends StatelessWidget {
  const HomeMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/homefix_logo.png', height: 32),
            const SizedBox(width: 8),
            const Text(
              'HomeFix',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text(
              'Login',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A00),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                elevation: 0,
              ),
              child: const Text('Sign Up'),
            ),
          ),
        ],

      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 HERO CARD (ICONIC MOBILE STYLE)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _MobileHeroCard(),
            ),

            const SizedBox(height: 12),

            // 🧰 SERVICES GRID
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Services',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: const [
                  MobileServiceCard(
                    title: 'Electrician',
                    image: 'assets/images/wiring.png',
                  ),
                  MobileServiceCard(
                    title: 'AC Service',
                    image: 'assets/images/appliance_service.png',
                  ),
                  MobileServiceCard(
                    title: 'Pipe Installation',
                    image: 'assets/images/pipe_installation.png',
                  ),
                  MobileServiceCard(
                    title: 'Drain Cleaning',
                    image: 'assets/images/drain_cleaning.png',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ⭐ TRUST STRIP
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _MobileTrustStrip(),
            ),

            const SizedBox(height: 24),

            // ℹ️ ABOUT CARD
            Padding(
              padding: const EdgeInsets.all(16),
              child: _MobileAboutCard(),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
class _MobileHeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFEFF4FF),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trusted Electrical &\nPlumbing Services',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Verified professionals at your doorstep.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A00),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Book Now'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                ),
                child: const Text('Explore'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class MobileServiceCard extends StatelessWidget {
  final String image;
  final String title;

  const MobileServiceCard({
    super.key,
    required this.image,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _MobileTrustStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TrustIcon(Icons.flash_on, 'Instant'),
          _TrustIcon(Icons.verified, 'Verified'),
          _TrustIcon(Icons.thumb_up, 'Guaranteed'),
        ],
      ),
    );
  }
}

class _TrustIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustIcon(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
class _MobileAboutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'About HomeFix',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'HomeFix connects you with verified electricians and plumbers '
                'for fast, reliable home services.',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
