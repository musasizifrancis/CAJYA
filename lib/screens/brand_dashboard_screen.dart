import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cajya/services/api_service.dart';

class BrandDashboardScreen extends StatefulWidget {
  final String? email;
  final String? userRole;

  const BrandDashboardScreen({
    this.email,
    this.userRole,
  });

  @override
  State<BrandDashboardScreen> createState() => _BrandDashboardScreenState();
}

class _BrandDashboardScreenState extends State<BrandDashboardScreen> {
  String _output = "Initializing...";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    String result = "";

    try {
      // Get user ID
      result += "STEP 1: Getting user ID...\n";
      final userId = await ApiService.getCurrentUserId();
      result += "User ID: $userId\n\n";

      if (userId == null) {
        result += "ERROR: No user ID\n";
        setState(() => _output = result);
        return;
      }

      // Get brand ID
      result += "STEP 2: Getting brand ID for user $userId...\n";
      final brandId = await ApiService.getBrandIdForUser(userId);
      result += "Brand ID: $brandId\n\n";

      if (brandId == null) {
        result += "ERROR: No brand found for this user\n";
        setState(() => _output = result);
        return;
      }

      // Get campaigns
      result += "STEP 3: Getting campaigns for brand $brandId...\n";
      final campaigns = await ApiService.getCampaignsByBrand(brandId);
      result += "Campaigns returned: ${campaigns.length}\n";
      result += "Raw data:\n${jsonEncode(campaigns)}\n\n";

      // If we have campaigns, get assignments for the first one
      if (campaigns.isNotEmpty) {
        final campaignId = campaigns[0]['id'];
        result += "STEP 4: Getting assignments for campaign $campaignId...\n";
        final assignments =
            await ApiService.getCampaignAssignments(campaignId);
        result += "Assignments returned: ${assignments.length}\n";
        result += "Raw data:\n${jsonEncode(assignments)}\n";
      }
    } catch (e, stack) {
      result += "EXCEPTION: $e\n$stack";
    }

    setState(() => _output = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brand Dashboard (DEBUG)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Raw API Output',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _output,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _output = "Refreshing...");
                _loadData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
