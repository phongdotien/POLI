import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({
    super.key,
    required this.formKey,
    required this.onSubmit,
    required this.isLoading, // Add isLoading property
    required this.emailController,  // Pass email controller
    required this.passwordController,  // Pass password controller
  });

  final GlobalKey<FormState> formKey;
  final Function(String, String) onSubmit; // Declare onSubmit callback
  final bool isLoading; // Track loading state
  final TextEditingController emailController;  // Accept email controller
  final TextEditingController passwordController;  // Accept password controller

  // Validate email format with regex
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Email TextField with validation
          TextFormField(
            controller: emailController,  // Use the passed controller
            validator: _validateEmail,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Email address",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Message.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withOpacity(0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),

          // Password TextField
          TextFormField(
            controller: passwordController,  // Use the passed controller
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Password",
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding * 0.75),
                child: SvgPicture.asset(
                  "assets/icons/Lock.svg",
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withOpacity(0.3),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: defaultPadding),

          // Continue Button
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    if (formKey.currentState!.validate()) {
                      // Form is valid, trigger sign-up
                      onSubmit(emailController.text, passwordController.text);
                    }
                  },
            child: isLoading
                ? CircularProgressIndicator()
                : const Text("Continue"),
          ),
        ],
      ),
    );
  }
}
