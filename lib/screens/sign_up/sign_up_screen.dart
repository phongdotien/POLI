import 'package:flutter/material.dart';

import '../../components/socal_card.dart';
import '../../constants.dart';
import 'components/sign_up_form.dart';

class SignUpScreen extends StatelessWidget {
  static String routeName = "/sign_up";

  const SignUpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text("Register Account", style: headingStyle),
                  const Text(
                    "Complete your details or continue \nwith social media",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const SignUpForm(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyIcon(),
                      SocalCard(
                        icon: "assets/icons/google-icon.svg",
                        press: () {},
                      ),
                      SocalCard(
                        icon: "assets/icons/facebook-2.svg",
                        press: () {},
                      ),
                      SocalCard(
                        icon: "assets/icons/twitter.svg",
                        press: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'By continuing your confirm that you agree \nwith our Term and Condition',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF7C7C7C)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(6.78016, 5.27997);
    path.cubicTo(6.92086, 5.42049, 6.99999, 5.61113, 7.00016, 5.80997);
    path.lineTo(7.00016, 6.18997);
    path.cubicTo(6.99786, 6.38839, 6.91905, 6.57825, 6.78016, 6.71997);
    path.lineTo(1.64016, 11.85);
    path.cubicTo(1.54628, 11.9446, 1.41848, 11.9979, 1.28516, 11.9979);
    path.cubicTo(1.15185, 11.9979, 1.02405, 11.9446, 0.930165, 11.85);
    path.lineTo(0.220165, 11.14);
    path.cubicTo(0.126101, 11.0478, 0.0730934, 10.9217, 0.0730934, 10.79);
    path.cubicTo(0.0730934, 10.6583, 0.126101, 10.5321, 0.220165, 10.44);
    path.lineTo(4.67016, 5.99997);
    path.lineTo(0.220165, 1.55997);
    path.cubicTo(0.125508, 1.46609, 0.0722656, 1.33829, 0.0722656, 1.20497);
    path.cubicTo(0.0722656, 1.07166, 0.125508, 0.943858, 0.220165, 0.849974);
    path.lineTo(0.930165, 0.149974);
    path.cubicTo(1.02405, 0.055318, 1.15185, 0.0020752, 1.28516, 0.0020752);
    path.cubicTo(1.41848, 0.0020752, 1.54628, 0.055318, 1.64016, 0.149974);
    path.lineTo(6.78016, 5.27997);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class MyIcon extends StatelessWidget {
  final double width;
  final double height;

  MyIcon({this.width = 7, this.height = 12});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: MyIconPainter(),
    );
  }
}
