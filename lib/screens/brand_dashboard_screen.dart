import 'package:flutter/material.dart';
import 'package:cajya/services/api_service.dart';
import 'package:cajya/screens/create_campaign_screen.dart';

class BrandDashboardScreen extends StatefulWidget {
  final String? email;

  const BrandDashboardScreen({
    Key? key,
    this.email,
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
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildCreateCampaignTab() {
    return CreateCampaignScreen();
  }

  Widget _buildActiveCampaignsTab() {
    return FutureBuilder<String?>(
      future: apiService.getCurrentUserId(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (userSnapshot.hasError) {
          return Center(child: Text('Error: ${userSnapshot.error}'));
        }

        final userId = userSnapshot.data;
        if (userId == null) {
          return const Center(child: Text('Unable to get user ID'));
        }

        return FutureBuilder<String?>(
          future: apiService.getBrandIdForUser(userId),
          builder: (context, brandSnapshot) {
            if (brandSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (brandSnapshot.hasError) {
              return Center(child: Text('Error: ${brandSnapshot.error}'));
            }

            final brandId = brandSnapshot.data;
            if (brandId == null) {
              return const Center(child: Text('Unable to get brand ID'));
            }

            return FutureBuilder<List<dynamic>>(
              future: apiService.getCampaignsByBrand(brandId),
              builder: (context, campaignsSnapshot) {
                if (campaignsSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (campaignsSnapshot.hasError) {
                  return Center(child: Text('Error: ${campaignsSnapshot.error}'));
                }

                final campaigns = campaignsSnapshot.data ?? [];
                if (campaigns.isEmpty) {
                  return const Center(child: Text('No active campaigns'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: campaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = campaigns[index];
                    return _buildCampaignCard(campaign);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCampaignCard(dynamic campaign) {
    final campaignId = campaign['id'];
    final campaignName = campaign['campaign_name'] ?? 'Unknown';
    final targetCity = campaign['target_city'] ?? 'N/A';
    final weeklyBudget = campaign['weekly_budget'] ?? 0;
    final durationWeeks = campaign['campaign_duration_weeks'] ?? 0;
    final driversNeeded = campaign['drivers_needed'];
    final status = campaign['status'] ?? 'active';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2196F3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaignName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$targetCity • Status: $status',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Weekly Budget', 'UGX ${weeklyBudget.toStringAsFixed(0)}'),
                _buildInfoRow('Duration', '$durationWeeks weeks'),
                if (driversNeeded != null)
                  _buildInfoRow('Drivers Needed', '$driversNeeded'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAssignedDrivers(campaignId),
                  icon: const Icon(Icons.people),
                  label: const Text('View Drivers'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignedDrivers(String campaignId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => FutureBuilder<List<dynamic>>(
          future: apiService.getCampaignAssignments(campaignId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return SizedBox(
                height: 200,
                child: Center(child: Text('Error: ${snapshot.error}')),
              );
            }

            final assignments = snapshot.data ?? [];
            
            // Filter for active assignments and extract driver profiles
            final drivers = assignments
                .where((a) => a['status'] == 'active')
                .map((a) => a['driver_profiles'])
                .where((d) => d != null)
                .toList();

            if (drivers.isEmpty) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No assigned drivers yet'),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              controller: scrollController,
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                final driver = drivers[index];
                return _buildDriverListItem(driver);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDriverListItem(dynamic driver) {
    final fullName = driver['users']?['full_name'] ?? 'Unknown Driver';
    final email = driver['users']?['email'] ?? 'N/A';
    final vehicleType = driver['vehicle_type'] ?? 'N/A';
    final licenseNumber = driver['license_number'] ?? 'N/A';
    final isVerified = driver['is_verified'] ?? false;

    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            fullName.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
      title: Text(
        fullName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(email, style: const TextStyle(fontSize: 12)),
          Text('$vehicleType • $licenseNumber',
              style: const TextStyle(fontSize: 12)),
        ],
      ),
      trailing: isVerified
          ? const Icon(Icons.verified, color: Colors.green)
          : const Icon(Icons.pending, color: Colors.orange),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCampaignsTab() {
    return const Center(
      child: Text('Completed Campaigns - Coming Soon'),
    );
  }

  Widget _buildAnalyticsTab() {
    return const Center(
      child: Text('Analytics - Coming Soon'),
    );
  }

  Widget _buildMessagesTab() {
    return const Center(
      child: Text('Messages - Coming Soon'),
    );
  }
}
