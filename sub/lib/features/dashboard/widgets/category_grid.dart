import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../models/category_models.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      CategoryModel(title: "Electrical", iconPath: "⚡"),
      CategoryModel(title: "Plumbing", iconPath: "🚰"),
      CategoryModel(title: "Appliance", iconPath: "🧺"),
      CategoryModel(title: "Cleaning", iconPath: "🧹"),
      CategoryModel(title: "Painting", iconPath: "🎨"),
      CategoryModel(title: "AC Repair", iconPath: "❄️"),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Categories",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];

            return GestureDetector(
              onTap: () {
                context.go(
                  "/services/${category.title}",
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius:
                  BorderRadius.circular(AppSizes.radius),
                  boxShadow: [
                    BoxShadow(
                      color:
                      Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Text(
                      category.iconPath,
                      style:
                      const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      category.title,
                      style: const TextStyle(
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
