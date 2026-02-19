import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/driver_auth_screen.dart';
import 'screens/brand_auth_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/driver_profile_screen.dart' as driver;
import 'screens/vehicle_registration_screen.dart';
import 'screens/brand_profile_screen.dart' as brand;
import 'screens/dashboard_screen.dart';
import 'screens/brand_dashboard_screen.dart';
import 'screens/withdrawal_screen.dart';
import 'screens/brand_campaign_creation_screen.dart';
import 'screens/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Supabase.initialize(
      url: 'https://nrwfehkdvaujcypvddhq.supabase.co',
      anonKey: 'sb_publishable_F7T3fQPmz6Zq1bFK25W4XQ_UP8ulQqG',
    );
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Supabase initialization failed: $e');
  }
  
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
        // Extract arguments from route settings
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final email = args['email'] as String? ?? '';
        final userRole = args['userRole'] as String? ?? 'driver';

        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/onboarding':
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
          case '/role-selection':
            return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
          case '/driver-auth':
            return MaterialPageRoute(builder: (_) => const DriverAuthScreen());
          case '/brand-auth':
            return MaterialPageRoute(builder: (_) => const BrandAuthScreen());
          case '/email-verification':
            return MaterialPageRoute(builder: (_) => const EmailVerificationScreen());
          case '/verification':
            return MaterialPageRoute(builder: (_) => const EmailVerificationScreen());
          case '/driver-profile':
            return MaterialPageRoute(builder: (_) => const driver.DriverProfileScreen());
          case '/vehicle-registration':
            return MaterialPageRoute(builder: (_) => VehicleDetailsScreen());
          case '/brand-profile':
            return MaterialPageRoute(builder: (_) => const brand.DriverProfileScreen());
          case '/dashboard':
            return MaterialPageRoute(
              builder: (_) => DashboardScreen(
                email: email,
                userRole: userRole,
              ),
            );
          case '/brand-dashboard':
            return MaterialPageRoute(
              builder: (_) => BrandDashboardScreen(
                email: email,
                userRole: userRole,
              ),
            );
          case '/withdrawal':
            return MaterialPageRoute(
              builder: (_) => WithdrawalScreen(
                email: email,
                userRole: userRole,
              ),
            );
          case '/brand-campaign':
            return MaterialPageRoute(builder: (_) => const BrandCampaignCreationScreen());
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
