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
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;

        switch (settings.name) {
          case '/onboarding':
            return MaterialPageRoute(
              builder: (context) => const OnboardingScreen(),
            );

          case '/role_selection':
            return MaterialPageRoute(
              builder: (context) => const RoleSelectionScreen(),
            );

          case '/driver_login':
            return MaterialPageRoute(
              builder: (context) => const DriverAuthScreen(),
            );

          case '/brand_login':
            return MaterialPageRoute(
              builder: (context) => const BrandAuthScreen(),
            );

          case '/email_verification':
            return MaterialPageRoute(
              builder: (context) => EmailVerificationScreen(
                email: args?['email'] ?? '',
              ),
            );

          case '/driver_profile':
            return MaterialPageRoute(
              builder: (context) => driver_screens.DriverProfileScreen(
                email: args?['email'] ?? '',
              ),
            );

          case '/vehicle_registration':
            return MaterialPageRoute(
              builder: (context) => VehicleRegistrationScreen(
                email: args?['email'] ?? '',
              ),
            );

          case '/brand_profile':
            return MaterialPageRoute(
              builder: (context) => brand_screens.BrandProfileScreen(
                email: args?['email'] ?? '',
              ),
            );

          case '/dashboard':
            return MaterialPageRoute(
              builder: (context) => DashboardScreen(
                email: args?['email'] ?? '',
                userRole: args?['userRole'] ?? 'driver',
              ),
            );

          case '/brand_dashboard':
            return MaterialPageRoute(
              builder: (context) => BrandDashboardScreen(
                email: args?['email'] ?? '',
              ),
            );

          case '/withdrawal':
            return MaterialPageRoute(
              builder: (context) => WithdrawalScreen(
                email: args?['email'] ?? '',
              ),
            );

          case '/brand_campaign':
            return MaterialPageRoute(
              builder: (context) => BrandCampaignCreationScreen(
                email: args?['email'] ?? '',
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (context) => const SplashScreen(),
            );
        }
      },
    );
  }
}

