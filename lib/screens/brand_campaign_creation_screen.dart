import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart';

class BrandCampaignCreationScreen extends StatefulWidget {
  final String? email;

  const BrandCampaignCreationScreen({Key? key, this.email}) : super(key: key);

  @override
  State<BrandCampaignCreationScreen> createState() =>
      _BrandCampaignCreationScreenState();
}

class _BrandCampaignCreationScreenState
    extends State<BrandCampaignCreationScreen> {
  final ApiService apiService = ApiService();

  final _campaignNameController = TextEditingController();
  final _targetCityController = TextEditingController();
  final _weeklyBudgetController = TextEditingController();
  final _campaignDurationController = TextEditingController();
  final _driversNeededController = TextEditingController();
  final _earningsPerWeekController = TextEditingController();

  @override
  void dispose() {
    _campaignNameController.dispose();
    _targetCityController.dispose();
    _weeklyBudgetController.dispose();
    _campaignDurationController.dispose();
    _driversNeededController.dispose();
    _earningsPerWeekController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Campaign'),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _campaignNameController,
              decoration: InputDecoration(
                labelText: 'Campaign Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.campaign),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _targetCityController,
              decoration: InputDecoration(
                labelText: 'Target City',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weeklyBudgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weekly Budget (\$)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _campaignDurationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Campaign Duration (weeks)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.date_range),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _driversNeededController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Drivers Needed',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _earningsPerWeekController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Driver Earnings per Week (\$)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.money),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _createCampaign,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 32,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Create Campaign',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createCampaign() async {
    if (_campaignNameController.text.isEmpty ||
        _targetCityController.text.isEmpty ||
        _weeklyBudgetController.text.isEmpty ||
        _campaignDurationController.text.isEmpty ||
        _driversNeededController.text.isEmpty ||
        _earningsPerWeekController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      // Get current user ID and brand ID
      final userId = await ApiService.getCurrentUserId();
      if (userId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      final brandId = await ApiService.getBrandIdForUser(userId);
      if (brandId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Brand not found')),
        );
        return;
      }

      // Create campaign
      final success = await ApiService.createCampaign(
        brandId: brandId,
        campaignName: _campaignNameController.text,
        targetCity: _targetCityController.text,
        weeklyBudget: double.parse(_weeklyBudgetController.text),
        campaignDurationWeeks: int.parse(_campaignDurationController.text),
        driversNeeded: int.parse(_driversNeededController.text),
        driverEarningsPerWeek:
            double.parse(_earningsPerWeekController.text),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Campaign created successfully!')),
        );
        // Clear fields
        _campaignNameController.clear();
        _targetCityController.clear();
        _weeklyBudgetController.clear();
        _campaignDurationController.clear();
        _driversNeededController.clear();
        _earningsPerWeekController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create campaign')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Get Supabase client
  static final _supabase = Supabase.instance.client;
}
