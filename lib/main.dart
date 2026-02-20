import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/main_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/driver_auth_screen.dart';
import 'screens/brand_auth_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/driver_profile_screen.dart';
import 'screens/brand_profile_screen.dart';
import 'screens/vehicle_details_screen.dart';
import 'screens/driver_dashboard_screen.dart';
import 'screens/brand_dashboard_screen.dart';
import 'screens/withdrawal_screen.dart';
import 'screens/brand_campaign_creation_screen.dart';
import 'screens/campaign_analytics_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nrwfehkdvaujcypvddhq.supabase.co',
    anonKey: 'sb_publishable_F7T3fQPmz6Zq1bFK25W4XQ_UP8ulQqG',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CAJYA',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        onGenerateRoute: (settings) {
          final args = settings.arguments as Map<String, dynamic>?;

          switch (settings.name) {
            case '/splash':
              return MaterialPageRoute(builder: (context) => const SplashScreen());

            case '/onboarding':
              return MaterialPageRoute(builder: (context) => const OnboardingScreen());

            case '/role-selection':
              return MaterialPageRoute(builder: (context) => const RoleSelectionScreen());

            case '/driver-auth':
              return MaterialPageRoute(builder: (context) => const DriverAuthScreen());

            case '/brand-auth':
              return MaterialPageRoute(builder: (context) => const BrandAuthScreen());

            case '/email-verification':
              return MaterialPageRoute(
                builder: (context) => const EmailVerificationScreen(),
                settings: RouteSettings(
                  name: settings.name,
                  arguments: args,
                ),
              );

            case '/driver-profile':
              return MaterialPageRoute(builder: (context) => const DriverProfileScreen());

            case '/brand-profile':
              return MaterialPageRoute(builder: (context) => const BrandProfileScreen());

            case '/vehicle-details':
              return MaterialPageRoute(builder: (context) => const VehicleDetailsScreen());

            case '/driver-dashboard':
              return MaterialPageRoute(
                builder: (context) => DriverDashboardScreen(
                  email: args?['email'] ?? '',
                ),
              );

            case '/brand-dashboard':
              return MaterialPageRoute(
                builder: (context) => BrandDashboardScreen(
                  email: args?['email'] ?? '',
                  userRole: args?['userRole'] ?? 'brand',
                ),
              );

            case '/withdrawal':
              return MaterialPageRoute(
                builder: (context) => WithdrawalScreen(
                  userRole: args?['userRole'] ?? 'brand',
                ),
              );

            case '/brand-campaign-creation':
              return MaterialPageRoute(
                builder: (context) => const BrandCampaignCreationScreen(),
              );

            case '/campaign-analytics':
              return MaterialPageRoute(
                builder: (context) => const CampaignAnalyticsScreen(),
              );

            case '/settings':
              return MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              );

            default:
              return MaterialPageRoute(builder: (context) => const SplashScreen());
          }
        },
      ),
    );
  }
}
