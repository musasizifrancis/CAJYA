import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/driver_auth_screen.dart';
import 'screens/brand_auth_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/driver_profile_screen.dart' as driver_screens;
import 'screens/vehicle_registration_screen.dart';
import 'screens/brand_profile_screen.dart' as brand_screens;
import 'screens/dashboard_screen.dart';
import 'screens/brand_dashboard_screen.dart';
import 'screens/withdrawal_screen.dart';
import 'screens/brand_campaign_creation_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CAJYA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
