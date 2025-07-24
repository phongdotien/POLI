import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shop/screens/auth/views/components/auth_service.dart';
import 'package:shop/screens/auth/views/components/sign_up_form.dart';
import 'package:shop/route/route_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

import '../../../constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService =
      AuthService(); // Create instance of AuthService
  bool _isLoading = false;

  // Controllers for email and password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Method to handle sign up
  Future<void> _signUp(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    User? user = await _authService.signUp(email, password);

    if (user != null) {
      await _initializeUserData(user);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Registration successful! Welcome ${user.email}"),
      ));
      // Navigate to the next screen after successful registration
      Navigator.pushNamedAndRemoveUntil(
        context,
        entryPointScreenRoute,
        ModalRoute.withName(logInScreenRoute),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Registration failed. Please try again."),
      ));
    }

    setState(() {
      _isLoading = false;
    });
  }

// Method to initialize user data in Firestore
  Future<void> _initializeUserData(User user) async {
    try {
      // Reference to the Firestore 'users' collection
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      // Initialize user data with default values: Rank: 2.0, Score: 0
      await users.doc(user.uid).set({
        // Use .doc(user.uid) to set the document ID to the user's UID
        'email': user.email,
        'rank_single': 2.0, // Default rank
        'score_single': 0, // Default score
        'rank_dual': 2.0, // Default rank
        'score_dual': 0, // Default score
        'time': FieldValue.serverTimestamp(), // Timestamp
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Failed to initialize user data."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/signUp_dark.png",
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Let’s get started!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Please enter your valid data in order to create an account.",
                  ),
                  const SizedBox(height: defaultPadding),
                  SignUpForm(
                    formKey: _formKey,
                    emailController: _emailController, // Pass the controller
                    passwordController:
                        _passwordController, // Pass the controller
                    isLoading: _isLoading,
                    onSubmit: (email, password) {
                      _signUp(email,
                          password); // Pass email and password to _signUp method
                    },
                  ),
                  const SizedBox(height: defaultPadding),
                  Row(
                    children: [
                      Checkbox(
                        onChanged: (value) {},
                        value: false,
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: "I agree with the",
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(
                                        context, termsOfServicesScreenRoute);
                                  },
                                text: " Terms of service ",
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const TextSpan(
                                text: "& privacy policy.",
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: defaultPadding * 2),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
