import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radius),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Expanded(
            child: Text(
              "20% OFF AC Service\nLimited Time Offer!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Icon(Icons.ac_unit, color: Colors.white, size: 60),
        ],
      ),
    );
  }
}
