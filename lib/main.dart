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
import 'screens/vehicle_details_screen.dart';
import 'screens/campaign_preview_screen.dart';
import 'screens/driver_profile_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/available_campaigns_screen.dart';
import 'screens/campaign_details_screen.dart';
import 'screens/messaging_screen.dart';
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
            case '/driver_auth':
              return MaterialPageRoute(
                builder: (_) => const DriverAuthScreen(),
                settings: settings,
              );
            case '/brand_auth':
              return MaterialPageRoute(
                builder: (_) => const BrandAuthScreen(),
                settings: settings,
              );
            case '/verification':
              return MaterialPageRoute(
                builder: (_) => VerificationScreen(
                  email: args?['email'] ?? '',
                  userRole: args?['userRole'] ?? 'driver',
                  userData: args?['userData'] ?? {},
                ),
                settings: settings,
              );
            case '/dashboard':
              return MaterialPageRoute(
                builder: (_) => _DashboardPage(
                  email: args?['email'] ?? '',
                  userRole: args?['userRole'] ?? 'driver',
                  userData: args?['userData'] ?? {},
                ),
                settings: settings,
              );
            case '/vehicle-details':
              return MaterialPageRoute(
                builder: (_) => const VehicleDetailsScreen(),
                settings: settings,
              );
            case '/campaign-preview':
              return MaterialPageRoute(
                builder: (_) => const CampaignPreviewScreen(),
                settings: settings,
              );
            case '/driver-profile':
              return MaterialPageRoute(
                builder: (_) => const DriverProfileScreen(),
                settings: settings,
              );
            case '/notifications':
              return MaterialPageRoute(
                builder: (_) => const NotificationScreen(),
                settings: settings,
              );
            case '/available-campaigns':
              return MaterialPageRoute(
                builder: (_) => const AvailableCampaignsScreen(),
                settings: settings,
              );
            case '/campaign-details':
              return MaterialPageRoute(
                builder: (_) => const CampaignDetailsScreen(),
                settings: settings,
              );
            case '/messaging':
              return MaterialPageRoute(
                builder: (_) => const MessagingScreen(),
                settings: settings,
              );
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

class _DashboardPage extends StatelessWidget {
  final String email;
  final String userRole;
  final Map<String, dynamic> userData;

  const _DashboardPage({
    required this.email,
    required this.userRole,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return _SafeDashboard(
      email: email,
      userRole: userRole,
      userData: userData,
    );
  }
}

class _SafeDashboard extends StatefulWidget {
  final String email;
  final String userRole;
  final Map<String, dynamic> userData;

  const _SafeDashboard({
    required this.email,
    required this.userRole,
    required this.userData,
  });

  @override
  State<_SafeDashboard> createState() => _SafeDashboardState();
}

class _SafeDashboardState extends State<_SafeDashboard> {
  late Future<Widget> dashboardFuture;

  @override
  void initState() {
    super.initState();
    dashboardFuture = _loadDashboard();
  }

  Future<Widget> _loadDashboard() async {
    try {
      final role = widget.userRole.toLowerCase().trim();

      if (role == 'brand') {
        return BrandDashboardScreen(
          email: widget.email,
          userData: widget.userData,
        );
      } else {
        return DashboardScreen(
          email: widget.email,
          userData: widget.userData,
        );
      }
    } catch (e) {
      return _ErrorPage(error: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _ErrorPage(error: snapshot.error.toString());
        }

        return snapshot.data ?? const SplashScreen();
      },
    );
  }
}

class _ErrorPage extends StatelessWidget {
  final String error;

  const _ErrorPage({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Dashboard Failed to Load',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


