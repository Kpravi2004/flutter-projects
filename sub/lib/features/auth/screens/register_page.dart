import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.padding),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                const Text(
                  "Create Account 🚀",
                  style: AppTextStyles.heading,
                ),
                const SizedBox(height: 8),

                const Text(
                  "Sign up to get started",
                  style: AppTextStyles.subHeading,
                ),

                const SizedBox(height: 40),

                const CustomTextField(hint: "Full Name"),
                const SizedBox(height: 20),

                const CustomTextField(hint: "Email Address"),
                const SizedBox(height: 20),

                const CustomTextField(
                  hint: "Password",
                  obscure: true,
                ),
                const SizedBox(height: 20),

                const CustomTextField(
                  hint: "Confirm Password",
                  obscure: true,
                ),
                const SizedBox(height: 30),

                CustomButton(
                  title: "Register",
                  onTap: () {
                    context.go("/home");
                  },
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        context.go("/login");
                      },
                      child: const Text(
                        "Login",
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
      ),
    );
  }
}
