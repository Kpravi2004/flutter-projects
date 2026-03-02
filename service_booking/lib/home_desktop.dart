import 'package:flutter/material.dart';

class HomeDesktop extends StatelessWidget {
  const HomeDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width * 0.08;

    return Scaffold(
    backgroundColor: const Color(0xFFF5F7FB),

    appBar: _buildAppBar(context),

    body: SingleChildScrollView(
    child: Column(
    children: [

    /// HERO
    _HeroSection(horizontalPadding: horizontalPadding),

    const SizedBox(height: 48),

    /// SERVICES
    Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    'Explore Our Services',
    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 24),

    GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: width > 900 ? 2 : 1,
    childAspectRatio: width > 900 ? 3 : 2.6,
    crossAxisSpacing: 20,
    mainAxisSpacing: 20,
    children: const [
    ServiceCard(
    title: 'Electrician',
    image: 'assets/images/wiring.png',
    ),
    ServiceCard(
    title: 'AC Service',
    image: 'assets/images/appliance_service.png',
    ),
    ServiceCard(
    title: 'Pipe Installation',
    image: 'assets/images/pipe_installation.png',
    ),
    ServiceCard(
    title: 'Drain Cleaning',
    image: 'assets/images/drain_cleaning.png',
    ),
    ],
    ),
    ],
    ),
    ),

    const SizedBox(height: 56),

    /// TRUST SECTION
    Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
    child: _TrustSection(),
    ),

    const SizedBox(height: 56),

    /// ABOUT
    Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
    child: _AboutSection(width: width),
    ),

    const SizedBox(height: 80),
    ],
    ),
    ),
    );

  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Image.asset('assets/homefix_logo.png', height: 36),
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
          child: const Text('Login'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
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
        const SizedBox(width: 16),
      ],
    );
  }

}
class _HeroSection extends StatelessWidget {
  final double horizontalPadding;

  const _HeroSection({super.key, required this.horizontalPadding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 32,
      ),
      child: AspectRatio(
          aspectRatio: 16 / 7, // matches reference image height
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
// HERO IMAGE (RIGHT SIDE, LARGE)
            Positioned.fill(
            child: Image.asset(
              'assets/images/services.png', // ✅ YOUR IMAGE
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),

      // LEFT SOFT GRADIENT (TEXT READABLE)
      Positioned.fill(
      child: Container(
          decoration: const BoxDecoration(
          gradient: LinearGradient(
          begin: Alignment.centerLeft,
      end: Alignment.centerRight,
          colors: [
          Color(0xFFFFFFFF),
      Color(0xEEFFFFFF),
      Colors.transparent,
      ],
    ),
    ),
    ),
    ),

    // TEXT CONTENT
    Padding(
    padding: const EdgeInsets.only(left: 48),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    'Trusted Electrical\n& Plumbing Services',
    style: TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    height: 1.2,
    ),
    ),
    const SizedBox(height: 12),
    const Text(
    'Verified professionals at your doorstep quickly & safely.',
    style: TextStyle(
    fontSize: 15,
    color: Colors.black54,
    ),
    ),
    const SizedBox(height: 24),
    Row(
    children: [
    ElevatedButton(
    onPressed: () {},
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.orange,
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(
    horizontal: 28,
    vertical: 14,
    ),
    ),
    child: const Text('Book Now'),
    ),
    const SizedBox(width: 16),
    OutlinedButton(
    onPressed: () {},
    style: OutlinedButton.styleFrom(
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(
    horizontal: 28,
    vertical: 14,
    ),
    ),
    child: const Text('Explore Services'),
    ),
    ],
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    ),
    );

  }
}

class ServiceCard extends StatelessWidget {
  final String image;
  final String title;

  const ServiceCard({super.key, required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 16 / 5, // banner-style like your image
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
          Positioned.fill(
          child: Image.asset(
            image, // ✅ wiring.png, appliance_service.png, etc.
            fit: BoxFit.cover,
          ),
        ),

    Positioned.fill(
    child: Container(
        decoration: const BoxDecoration(
        gradient: LinearGradient(
        begin: Alignment.bottomLeft,
    end: Alignment.topRight,
        colors: [
        Color(0xAA000000),
    Colors.transparent,
    ],
    ),
    ),
    ),
    ),

    Positioned(
    left: 20,
    bottom: 20,
    child: Text(
    title,
    style: const TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    ),
    ],
    ),
    ),
    );

  }
}
class _TrustSection extends StatelessWidget {
  const _TrustSection();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/services.png'),
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
          ),
        ),
        child: Stack(
          children: [
            // WHITE OVERLAY (READABILITY)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xEEFFFFFF),
                      Color(0xCCFFFFFF),
                    ],
                  ),
                ),
              ),
            ),

            // CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  TrustItem(
                    Icons.flash_on,
                    'Instant Booking',
                    subtitle: 'Quick & easy service',
                  ),
                  TrustItem(
                    Icons.verified,
                    'Verified Professionals',
                    subtitle: 'Background checked',
                  ),
                  TrustItem(
                    Icons.thumb_up,
                    'Service Guarantee',
                    subtitle: 'Quality assured',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class TrustItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const TrustItem(
      this.icon,
      this.title, {
        required this.subtitle,
        super.key,
      });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: Colors.white,
          child: Icon(icon, size: 30, color: Colors.blue),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  final double width;

  const _AboutSection({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(28)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEFF6FF),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'About HomeFix',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),

          Text(
            'HomeFix is a smart home service platform designed to connect '
                'customers with trusted and verified electricians and plumbers '
                'near their location.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.6,
            ),
          ),

          SizedBox(height: 12),

          Text(
            'Our mission is to make home maintenance simple, fast, and reliable. '
                'With instant booking, transparent pricing, and background-verified '
                'professionals, HomeFix ensures quality service right at your doorstep.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black54,
              height: 1.6,
            ),
          ),

          SizedBox(height: 12),

          Text(
            'Whether it is electrical repairs, plumbing work, AC servicing, '
                'or drain cleaning, HomeFix delivers professional solutions '
                'within minutes — safely and efficiently.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
