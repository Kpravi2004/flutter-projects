import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_colors.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Hello, Machi 👋",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                )),
            SizedBox(height: 4),
            Text("Find your service",
                style: AppTextStyles.heading),
          ],
        ),
        const CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary,
          child: Icon(Icons.person, color: Colors.white),
        )
      ],
    );
  }
}
