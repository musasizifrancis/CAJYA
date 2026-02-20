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

            // Photo verification (after driver auth)
            case '/verification':
              return MaterialPageRoute(
                builder: (context) => VerificationScreen(
                  email: args?['email'] ?? 'driver@example.com',
                  userRole: args?['userRole'] ?? 'driver',
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
              return MaterialPageRoute(
                builder: (context) => DashboardScreen(
                  email: args?['email'] ?? 'driver@example.com',
                  userRole: args?['userRole'] ?? 'driver',
                ),
              );

            case '/brand-dashboard':
              return MaterialPageRoute(
                builder: (context) => BrandDashboardScreen(
                  email: args?['email'] ?? 'brand@example.com',
                  userRole: args?['userRole'] ?? 'brand',
                ),
              );

            case '/withdrawal':
              return MaterialPageRoute(
                builder: (context) => WithdrawalScreen(
                  email: args?['email'] ?? 'user@example.com',
                  userRole: args?['userRole'] ?? 'brand',
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
        },
      ),
    );
  }
}

// Placeholder for CampaignPreviewScreen
class CampaignPreviewScreen extends StatelessWidget {
  final Map<String, dynamic> campaignData;

  const CampaignPreviewScreen({
    Key? key,
    required this.campaignData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign Preview'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Campaign Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Name:', campaignData['name'] ?? 'N/A'),
            _buildDetailRow('Type:', campaignData['type'] ?? 'N/A'),
            _buildDetailRow('Budget:', '\$${campaignData['budget'] ?? "N/A"}'),
            _buildDetailRow('Start Date:', campaignData['startDate'] ?? 'N/A'),
            _buildDetailRow('End Date:', campaignData['endDate'] ?? 'N/A'),
            const SizedBox(height: 20),
            const Text(
              'Description:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(campaignData['description'] ?? 'N/A'),
            const SizedBox(height: 20),
            const Text(
              'Target Audience:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(campaignData['audience'] ?? 'N/A'),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Campaign published!')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('PUBLISH CAMPAIGN'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

