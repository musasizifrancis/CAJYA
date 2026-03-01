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
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brand Dashboard'),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Tooltip(
              message: 'Document Verification Panel',
              child: IconButton(
                icon: const Icon(Icons.verified_user, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/admin-verification');
                },
              ),
            ),
          ),
        ],
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
                    final driverName = (driverProfiles != null && driverProfiles is Map) ? (driverProfiles['users']?['full_name'] ?? 'Unknown') : 'Unknown';
                    
                    final driverEmail = (driverProfiles != null && driverProfiles is Map) ? (driverProfiles['users']?['email'] ?? 'N/A') : 'N/A';

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
    return FutureBuilder<String?>(
      future: ApiService.getCurrentUserId(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final userId = userSnapshot.data!;
        return FutureBuilder<String?>(
          future: ApiService.getBrandIdForUser(userId),
          builder: (context, brandSnapshot) {
            if (!brandSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final brandId = brandSnapshot.data!;
            return FutureBuilder<List<dynamic>>(
              future: ApiService.getCampaignsByBrand(brandId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final completedCampaigns = (snapshot.data ?? [])
                    .where((c) => c['status'] == 'completed' || c['status'] == 'inactive')
                    .toList();
                if (completedCampaigns.isEmpty) {
                  return const Center(
                    child: Text('No completed campaigns yet'),
                  );
                }
                return ListView.builder(
                  itemCount: completedCampaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = completedCampaigns[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(campaign['campaign_name'] ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('City: ${campaign['target_city'] ?? 'N/A'}'),
                            Text('Duration: ${campaign['campaign_duration_weeks'] ?? 0} weeks'),
                            Text('Status: ${campaign['status'] ?? 'N/A'}'),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(campaign['status'] ?? 'Unknown'),
                          backgroundColor: Colors.grey[300],
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

  Widget _buildAnalyticsTab() {
    return FutureBuilder<String?>(
      future: ApiService.getCurrentUserId(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final userId = userSnapshot.data!;
        return FutureBuilder<String?>(
          future: ApiService.getBrandIdForUser(userId),
          builder: (context, brandSnapshot) {
            if (!brandSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final brandId = brandSnapshot.data!;
            return FutureBuilder<List<dynamic>>(
              future: ApiService.getCampaignsByBrand(brandId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final campaigns = snapshot.data ?? [];
                final activeCampaigns = campaigns.where((c) => c['status'] == 'active').length;
                final completedCampaigns = campaigns.where((c) => c['status'] == 'completed').length;
                final totalBudget = campaigns.fold(0.0, (sum, c) => sum + (double.tryParse(c['weekly_budget'].toString()) ?? 0));
                
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Campaigns', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            Text('${campaigns.length}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Active Campaigns', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            Text('$activeCampaigns', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Completed Campaigns', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            Text('$completedCampaigns', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Budget', style: TextStyle(fontSize: 14, color: Colors.grey)),
                            Text('\$${totalBudget.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange)),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMessagesTab() {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF2196F3),
            child: const Text(
              'Brand-Driver Messages',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mail, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text(
                        'No Messages Yet',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Messages with drivers will appear here',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message feature coming soon')),
          );
        },
        child: const Icon(Icons.message),
      ),
    );
  }
}
