import 'package:flutter/widgets.dart';

import 'screens/complete_profile/complete_profile_screen.dart';
import 'screens/login_success/login_success_screen.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  // InitScreen.routeName: (context) => const InitScreen(),
  // SplashScreen.routeName: (context) => const SplashScreen(),
  // SignInScreen.routeName: (context) => const SignInScreen(),
  // ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
  LoginSuccessScreen.routeName: (context) => const LoginSuccessScreen(),
  // SignUpScreen.routeName: (context) => const SignUpScreen(),
  CompleteProfileScreen.routeName: (context) => const CompleteProfileScreen(),
  // OtpScreen.routeName: (context) => const OtpScreen(),
  // HomeScreen.routeName: (context) => const HomeScreen(),
  // ProductsScreen.routeName: (context) => const ProductsScreen(),
  // DetailsScreen.routeName: (context) => const DetailsScreen(),
  // CartScreen.routeName: (context) => const CartScreen(),
  // ProfileScreen.routeName: (context) => const ProfileScreen(),
};
