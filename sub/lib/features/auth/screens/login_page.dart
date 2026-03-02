import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              /// Title
              const Text(
                "Welcome Back 👋",
                style: AppTextStyles.heading,
              ),
              const SizedBox(height: 8),

              const Text(
                "Login to continue booking services",
                style: AppTextStyles.subHeading,
              ),

              const SizedBox(height: 40),

              /// Email Field
              const CustomTextField(
                hint: "Email Address",
              ),

              const SizedBox(height: 20),

              /// Password Field
              const CustomTextField(
                hint: "Password",
                obscure: true,
              ),

              const SizedBox(height: 30),

              /// Login Button
              CustomButton(
                title: "Login",
                onTap: () {
                  context.go("/home");
                },
              ),

              const SizedBox(height: 20),

              /// Register Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      context.go("/register");
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
