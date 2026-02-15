import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

const String supabaseUrl = 'https://nrwfehkdvaujcypvddhq.supabase.co';
const String supabaseAnonKey = 'sb_publishable_F7T3fQPmz6Zq1bFK25W4XQ_UP8ulQqG';

Future<void> main() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarJa - Driver Advertising',
      theme: ThemeData(
        primaryColor: const Color(0xFF001a4d),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003d99),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/driver-auth': (context) => const DriverAuthScreen(),
        '/brand-auth': (context) => const BrandAuthScreen(),
        '/email-verification': (context) => const EmailVerificationScreen(),
        '/driver-profile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return driver_screens.DriverProfileScreen(
            initialData: args ?? {},
          );
        },
        '/vehicle-registration': (context) => VehicleDetailsScreen(),
        '/brand-profile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return brand_screens.DriverProfileScreen(
            initialData: args ?? {},
          );
        },
        '/dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final email = args?['email'] ?? '';
          final userRole = args?['userRole'] ?? 'DRIVER';
          return DashboardScreen(
            email: email,
            userRole: userRole,
          );
        },
        '/brand-dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final email = args?['email'] ?? '';
          final userRole = args?['userRole'] ?? 'BRAND';
          return BrandDashboardScreen(
            email: email,
            userRole: userRole,
          );
        },
        '/brand-profile-screen': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return brand_screens.DriverProfileScreen(
            initialData: args ?? {},
          );
        },
        '/withdrawal': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final email = args?['email'] ?? '';
          final userRole = args?['userRole'] ?? 'DRIVER';
          return WithdrawalScreen(
            email: email,
            userRole: userRole,
          );
        },
        '/campaign-creation': (context) => const BrandCampaignCreationScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Route Error'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Route not found: ${settings.name}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/splash',
                        (route) => false,
                      );
                    },
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
