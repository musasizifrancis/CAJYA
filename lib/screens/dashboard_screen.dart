import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _driverId;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeUser();
  }

  void _initializeUser() {
    _userId = Supabase.instance.client.auth.currentUser?.id;
    _driverId = _userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Available'),
            Tab(text: 'My Campaigns'),
            Tab(text: 'Earnings'),
            Tab(text: 'Profile'),
            Tab(text: 'Messages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvailableCampaigns(),
          _buildMyCampaigns(),
          _buildEarnings(),
          _buildProfile(),
          _buildMessages(),
        ],
      ),
    );
  }

  // TAB 1: AVAILABLE CAMPAIGNS
  Widget _buildAvailableCampaigns() {
    if (_driverId == null) return const Center(child: Text('Error loading driver'));

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ApiService.getAvailableCampaigns(_driverId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No campaigns available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final campaign = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(campaign['campaign_name'] ?? 'Unknown'),
                subtitle: Text(campaign['target_city'] ?? 'Unknown location'),
                trailing: ElevatedButton(
                  onPressed: () => _applyCampaign(campaign['id']),
                  child: const Text('Apply'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _applyCampaign(String campaignId) async {
    if (_driverId == null) return;

    final success = await ApiService.applyForCampaign(_driverId!, campaignId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Applied successfully!')),
      );
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to apply')),
      );
    }
  }

  // TAB 2: MY CAMPAIGNS
  Widget _buildMyCampaigns() {
    if (_driverId == null) return const Center(child: Text('Error loading driver'));

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ApiService.getDriverCampaigns(_driverId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No active campaigns'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final assignment = snapshot.data![index];
            final campaign = assignment['campaigns'];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign['campaign_name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Location: ${campaign['target_city'] ?? 'Unknown'}'),
                    Text('Status: ${assignment['status'] ?? 'active'}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // TAB 3: EARNINGS
  Widget _buildEarnings() {
    if (_driverId == null) return const Center(child: Text('Error loading driver'));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<double>(
              future: ApiService.getTotalEarnings(_driverId!),
              builder: (context, snapshot) {
                return Card(
                  color: Colors.green[100],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Earnings'),
                        const SizedBox(height: 8),
                        Text(
                          '\$${snapshot.data?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Withdrawal History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: ApiService.getWithdrawalHistory(_driverId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No withdrawal history');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final withdrawal = snapshot.data![index];
                    return ListTile(
                      title: Text('\$${withdrawal['amount']}'),
                      subtitle: Text(withdrawal['payment_method'] ?? 'Unknown'),
                      trailing: Text(withdrawal['status'] ?? 'pending'),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showWithdrawalDialog(),
              child: const Text('Request Withdrawal'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawalDialog() {
    final amountController = TextEditingController();
    String paymentMethod = 'bank_transfer';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Withdrawal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: paymentMethod,
              onChanged: (value) {
                paymentMethod = value ?? 'bank_transfer';
              },
              items: const [
                DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                DropdownMenuItem(value: 'mobile_money', child: Text('Mobile Money')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_driverId != null && amountController.text.isNotEmpty) {
                final success = await ApiService.requestWithdrawal(
                  driverId: _driverId!,
                  amount: double.parse(amountController.text),
                  paymentMethod: paymentMethod,
                );
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Withdrawal requested!')),
                  );
                  setState(() {});
                }
              }
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  // TAB 4: PROFILE
  Widget _buildProfile() {
    if (_driverId == null) return const Center(child: Text('Error loading driver'));

    return FutureBuilder<Map<String, dynamic>?>(
      future: ApiService.getDriverProfile(_driverId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = snapshot.data;
        if (profile == null) {
          return const Center(child: Text('Profile not found'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Driver Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text('National ID: ${profile['national_id'] ?? 'Not provided'}'),
                    const SizedBox(height: 8),
                    Text('Licence Number: ${profile['licence_number'] ?? 'Not provided'}'),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // TAB 5: MESSAGES
  Widget _buildMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.message, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Messages coming soon'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
