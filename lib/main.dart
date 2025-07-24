import 'package:flutter/material.dart';
import 'package:shop/navigate_obs.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/route/router.dart' as router;
import 'package:shop/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import the package

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1440, 900), //Design size of your Figma File
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Shop Template by The Flutter Way',
          theme: AppTheme.lightTheme(context),
          // Dark theme is included in the Full template
          themeMode: ThemeMode.light,
          onGenerateRoute: router.generateRoute,
          initialRoute: onbordingScreenRoute,
        );
      },
    );
  }
}
