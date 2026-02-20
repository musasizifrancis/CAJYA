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
import 'screens/verification_screen.dart';
import 'screens/driver_profile_screen.dart';
import 'screens/brand_profile_screen.dart' as brand_profile;
import 'screens/vehicle_registration_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/brand_dashboard_screen.dart';
import 'screens/brand_campaign_creation_screen.dart';
import 'screens/withdrawal_screen.dart';

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
          try {
            final args = settings.arguments as Map<String, dynamic>?;

            switch (settings.name) {
              case '/splash':
                return MaterialPageRoute(
                  builder: (context) => const SplashScreen(),
                );

              case '/onboarding':
                return MaterialPageRoute(
                  builder: (context) => const OnboardingScreen(),
                );

              case '/role_selection':
                return MaterialPageRoute(
                  builder: (context) => const RoleSelectionScreen(),
                );

              case '/driver-auth':
                return MaterialPageRoute(
                  builder: (context) => const DriverAuthScreen(),
                );

              case '/brand-auth':
                return MaterialPageRoute(
                  builder: (context) => const BrandAuthScreen(),
                );

              // Email verification (after sign-up email sent)
              case '/email-verification':
                return MaterialPageRoute(
                  builder: (context) => const EmailVerificationScreen(),
                  settings: RouteSettings(
                    name: settings.name,
                    arguments: args,
                  ),
                );

              // Photo verification (after driver/brand auth)
              case '/verification':
                final email = args?['email'] as String? ?? 'unknown@example.com';
                final userRole = (args?['userRole'] as String? ?? 'driver').toLowerCase();
                return MaterialPageRoute(
                  builder: (context) => VerificationScreen(
                    email: email,
                    userRole: userRole,
                  ),
                );

              case '/driver-profile':
                return MaterialPageRoute(
                  builder: (context) => DriverProfileScreen(
                    initialData: args ?? {},
                  ),
                );

              case '/brand-profile':
                return MaterialPageRoute(
                  builder: (context) => brand_profile.DriverProfileScreen(
                    initialData: args ?? {},
                  ),
                );

              // Vehicle details (from driver_profile or brand_profile)
              case '/vehicle-details':
                return MaterialPageRoute(
                  builder: (context) => const VehicleDetailsScreen(),
                );

              case '/dashboard':
                final email = args?['email'] as String? ?? 'driver@example.com';
                final userRole = (args?['userRole'] as String? ?? 'driver').toLowerCase();
                return MaterialPageRoute(
                  builder: (context) => _SafeDashboardWrapper(
                    email: email,
                    userRole: userRole,
                  ),
                );

              case '/brand-dashboard':
                final email = args?['email'] as String? ?? 'brand@example.com';
                final userRole = (args?['userRole'] as String? ?? 'brand').toLowerCase();
                return MaterialPageRoute(
                  builder: (context) => _SafeBrandDashboardWrapper(
                    email: email,
                    userRole: userRole,
                  ),
                );

              case '/withdrawal':
                final email = args?['email'] as String? ?? 'user@example.com';
                final userRole = args?['userRole'] as String? ?? 'brand';
                return MaterialPageRoute(
                  builder: (context) => WithdrawalScreen(
                    email: email,
                    userRole: userRole,
                  ),
                );

              case '/brand-campaign-creation':
                return MaterialPageRoute(
                  builder: (context) => const BrandCampaignCreationScreen(),
                );

              // Campaign preview (from brand_campaign_creation)
              case '/campaign-preview':
                return MaterialPageRoute(
                  builder: (context) => CampaignPreviewScreen(
                    campaignData: args ?? {},
                  ),
                );

              default:
                return MaterialPageRoute(
                  builder: (context) => const SplashScreen(),
                );
            }
          } catch (e) {
            // Error handler - return error screen
            return MaterialPageRoute(
              builder: (context) => ErrorScreen(error: e.toString()),
            );
          }
        },
      ),
    );
  }
}

// SAFETY WRAPPERS FOR GOOGLE MAPS DASHBOARDS
class _SafeDashboardWrapper extends StatefulWidget {
  final String email;
  final String userRole;

  const _SafeDashboardWrapper({
    required this.email,
    required this.userRole,
  });

  @override
  State<_SafeDashboardWrapper> createState() => _SafeDashboardWrapperState();
}

class _SafeDashboardWrapperState extends State<_SafeDashboardWrapper> {
  bool _hasError = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error Loading Dashboard')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error: $_errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return _ErrorBoundary(
      onError: (error) {
        setState(() {
          _hasError = true;
          _errorMessage = error;
        });
      },
      child: DashboardScreen(
        email: widget.email,
        userRole: widget.userRole,
      ),
    );
  }
}

class _SafeBrandDashboardWrapper extends StatefulWidget {
  final String email;
  final String userRole;

  const _SafeBrandDashboardWrapper({
    required this.email,
    required this.userRole,
  });

  @override
  State<_SafeBrandDashboardWrapper> createState() =>
      _SafeBrandDashboardWrapperState();
}

class _SafeBrandDashboardWrapperState extends State<_SafeBrandDashboardWrapper> {
  bool _hasError = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error Loading Dashboard')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error: $_errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return _ErrorBoundary(
      onError: (error) {
        setState(() {
          _hasError = true;
          _errorMessage = error;
        });
      },
      child: BrandDashboardScreen(
        email: widget.email,
        userRole: widget.userRole,
      ),
    );
  }
}

// ERROR BOUNDARY WIDGET
class _ErrorBoundary extends StatelessWidget {
  final Widget child;
  final Function(String) onError;

  const _ErrorBoundary({
    required this.child,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: child,
    );
  }
}

// ERROR SCREEN
class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'An error occurred:\n\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/splash',
                (route) => false,
              ),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for CampaignPreviewScreen
class CampaignPreviewScreen extends StatelessWidget {
  final Map<String, dynamic> campaignData;

  const CampaignPreviewScreen({required this.campaignData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campaign Preview')),
      body: Center(
        child: Text('Campaign Data: ${campaignData.toString()}'),
      ),
    );
  }
}


