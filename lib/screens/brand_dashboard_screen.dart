import 'package:flutter/material.dart';
import 'package:cajya/services/api_service.dart';
import 'package:cajya/screens/brand_campaign_creation_screen.dart';

class BrandDashboardScreen extends StatefulWidget {
  final String? email;
  final String? userRole;

  const BrandDashboardScreen({
    Key? key,
    this.email,
    this.userRole,
  }) : super(key: key);

  @override
  State<BrandDashboardScreen> createState() => _BrandDashboardScreenState();
}

class _BrandDashboardScreenState extends State<BrandDashboardScreen> {
  final ApiService apiService = ApiService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brand Dashboard'),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildCreateCampaignTab(),
          _buildActiveCampaignsTab(),
          _buildCompletedCampaignsTab(),
          _buildAnalyticsTab(),
          _buildMessagesTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Active',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Completed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
        ],
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  Widget _buildCreateCampaignTab() {
    return BrandCampaignCreationScreen(email: widget.email);
  }

  Widget _buildActiveCampaignsTab() {
    return FutureBuilder<String?>(
      future: ApiService.getCurrentUserId(),
      builder: (context, userIdSnapshot) {
        if (!userIdSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userId = userIdSnapshot.data!;

        return FutureBuilder<String?>(
          future: ApiService.getBrandIdForUser(userId),
          builder: (context, brandIdSnapshot) {
            if (!brandIdSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final brandId = brandIdSnapshot.data!;

            return FutureBuilder<List<Map<String, dynamic>>>(
              future: ApiService.getCampaignsByBrand(brandId),
              builder: (context, campaignsSnapshot) {
                if (!campaignsSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final campaigns = campaignsSnapshot.data!;

                if (campaigns.isEmpty) {
                  return const Center(
                    child: Text('No active campaigns yet. Create one!'),
                  );
                }

                return ListView.builder(
                  itemCount: campaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = campaigns[index];
                    final campaignId = campaign['id'];
                    final campaignName = campaign['campaign_name'] ?? 'Unknown';

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(campaignName),
                        subtitle: Text(
                          'Budget: \$${campaign['weekly_budget']?.toString() ?? '0'}/week',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            _showDriversDialog(campaignId, campaignName);
                          },
                          child: const Text('View Drivers'),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _showDriversDialog(String campaignId, String campaignName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Drivers - $campaignName'),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: ApiService.getCampaignAssignments(campaignId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final assignments = snapshot.data!;

                if (assignments.isEmpty) {
                  return const Text('No assigned drivers yet');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = assignments[index];
                    
                    // Extract driver data from nested structure
                    final driverProfiles = assignment['driver_profiles'];
                    final driverName = driverProfiles != null && driverProfiles is Map
                        ? driverProfiles['users']?['full_name'] ?? 'Unknown'
                        : 'Unknown';
                    
                    final driverEmail = driverProfiles != null && driverProfiles is Map
                        ? driverProfiles['users']?['email'] ?? 'N/A'
                        : 'N/A';

                    final vehicleType = driverProfiles != null && driverProfiles is Map
                        ? driverProfiles['vehicle_type'] ?? 'N/A'
                        : 'N/A';

                    final status = assignment['status'] ?? 'unknown';

                    return ListTile(
                      title: Text(driverName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: $driverEmail'),
                          Text('Vehicle: $vehicleType'),
                          Text('Status: $status'),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompletedCampaignsTab() {
    return const Center(
      child: Text('Completed Campaigns (Coming Soon)'),
    );
  }

  Widget _buildAnalyticsTab() {
    return const Center(
      child: Text('Analytics (Coming Soon)'),
    );
  }

  Widget _buildMessagesTab() {
    return const Center(
      child: Text('Messages (Coming Soon)'),
    );
  }
}
