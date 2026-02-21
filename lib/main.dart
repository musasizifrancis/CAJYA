import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/driver_auth_screen.dart';
import 'screens/brand_auth_screen.dart';
import 'screens/verification_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/brand_dashboard_screen.dart';
import 'providers/main_provider.dart';

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
    return ChangeNotifierProvider(
      create: (context) => MainProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CAJYA',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const SplashScreen(),
        onGenerateRoute: (RouteSettings settings) {
          final args = settings.arguments as Map<String, dynamic>?;

          switch (settings.name) {
            case '/onboarding':
              return MaterialPageRoute(
                builder: (_) => const OnboardingScreen(),
                settings: settings,
              );
            case '/role_selection':
              return MaterialPageRoute(
                builder: (_) => const RoleSelectionScreen(),
                settings: settings,
              );
            // FIXED: Changed from /driver_auth to /driver-auth (with hyphen)
            case '/driver-auth':
              return MaterialPageRoute(
                builder: (_) => const DriverAuthScreen(),
                settings: settings,
              );
            // FIXED: Changed from /brand_auth to /brand-auth (with hyphen)
            case '/brand-auth':
              return MaterialPageRoute(
                builder: (_) => const BrandAuthScreen(),
                settings: settings,
              );
            case '/verification':
              return MaterialPageRoute(
                builder: (_) => VerificationScreen(
                  email: args?['email'] ?? '',
                  userRole: args?['userRole'] ?? 'driver',
                ),
                settings: settings,
              );
            case '/dashboard':
              final email = args?['email'] ?? '';
              final userRole = (args?['userRole'] ?? 'driver').toString().toLowerCase().trim();

              // Load correct dashboard based on userRole
              if (userRole == 'brand') {
                return MaterialPageRoute(
                  builder: (_) => BrandDashboardScreen(
                    email: email,
                    userRole: userRole,
                  ),
                  settings: settings,
                );
              } else {
                return MaterialPageRoute(
                  builder: (_) => DashboardScreen(
                    email: email,
                    userRole: userRole,
                  ),
                  settings: settings,
                );
              }
            default:
              return MaterialPageRoute(
                builder: (_) => const SplashScreen(),
                settings: settings,
              );
          }
        },
      ),
    );
  }
}



