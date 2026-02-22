import 'package:flutter/material.dart';
import 'api_service.dart';

class BrandCampaignCreationScreen extends StatefulWidget {
  const BrandCampaignCreationScreen({Key? key}) : super(key: key);

  @override
  State<BrandCampaignCreationScreen> createState() =>
      _BrandCampaignCreationScreenState();
}

class _BrandCampaignCreationScreenState
    extends State<BrandCampaignCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers - matching database schema
  final _campaignNameController = TextEditingController();
  final _targetCityController = TextEditingController();
  final _weeklyBudgetController = TextEditingController();
  final _durationWeeksController = TextEditingController();
  final _driverEarningsController = TextEditingController();

  @override
  void dispose() {
    _campaignNameController.dispose();
    _targetCityController.dispose();
    _weeklyBudgetController.dispose();
    _durationWeeksController.dispose();
    _driverEarningsController.dispose();
    super.dispose();
  }

  void _submitCampaign() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get current user and their brand ID
      final userId = await ApiService.getCurrentUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not authenticated')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final brandId = await ApiService.getBrandIdForUser(userId);
      if (brandId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Brand profile not found')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Create campaign in Supabase
      final success = await _supabase.client.from('campaigns').insert({
        'brand_id': brandId,
        'campaign_name': _campaignNameController.text,
        'target_city': _targetCityController.text,
        'weekly_budget': double.parse(_weeklyBudgetController.text),
        'campaign_duration_weeks': int.parse(_durationWeeksController.text),
        'driver_earnings_per_week': double.parse(_driverEarningsController.text),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Campaign created successfully!')),
      );

      // Clear form and navigate back
      _campaignNameController.clear();
      _targetCityController.clear();
      _weeklyBudgetController.clear();
      _durationWeeksController.clear();
      _driverEarningsController.clear();

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating campaign: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Campaign'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campaign Name
              const Text(
                'Campaign Name *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _campaignNameController,
                decoration: InputDecoration(
                  hintText: 'e.g., Summer Sale 2026',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.campaign),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campaign name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Target City
              const Text(
                'Target City *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _targetCityController,
                decoration: InputDecoration(
                  hintText: 'e.g., Kampala',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Target city is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Weekly Budget
              const Text(
                'Weekly Budget (USD) *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _weeklyBudgetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'e.g., 200',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Weekly budget is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campaign Duration (Weeks)
              const Text(
                'Campaign Duration (Weeks) *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _durationWeeksController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g., 4',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.date_range),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campaign duration is required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (int.parse(value) < 1) {
                    return 'Duration must be at least 1 week';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Driver Earnings Per Week
              const Text(
                'Driver Earnings Per Week (USD) *',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _driverEarningsController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'e.g., 150',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.monetization_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Driver earnings is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitCampaign,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003d99),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'CREATE CAMPAIGN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Get Supabase client
  static final _supabase = Supabase.instance.client;
}

import 'package:supabase_flutter/supabase_flutter.dart';