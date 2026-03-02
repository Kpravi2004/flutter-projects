import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.padding),
        child: Column(
          children: [

            /// Profile Avatar
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            /// Name
            const Text(
              "Machi",
              style: AppTextStyles.heading,
            ),

            const SizedBox(height: 5),

            const Text(
              "machi@email.com",
              style: AppTextStyles.subHeading,
            ),

            const SizedBox(height: 40),

            /// Menu Items
            _buildTile(
              icon: Icons.history,
              title: "My Bookings",
              onTap: () {},
            ),

            _buildTile(
              icon: Icons.settings,
              title: "Settings",
              onTap: () {},
            ),

            _buildTile(
              icon: Icons.help_outline,
              title: "Help & Support",
              onTap: () {},
            ),

            const Spacer(),

            /// Logout Button
            CustomButton(
              title: "Logout",
              onTap: () {
                context.go("/login");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
