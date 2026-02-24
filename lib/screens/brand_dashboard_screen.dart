import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';

class BrandDashboardScreen extends StatefulWidget {
  final String? email;
  final String? userRole;
  
  const BrandDashboardScreen({Key? key, this.email, this.userRole}) : super(key: key);

  @override
  State<BrandDashboardScreen> createState() => _BrandDashboardScreenState();
}

class _BrandDashboardScreenState extends State<BrandDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _brandId;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeUser();  // This is async but we don't need to await
  }

  Future<void> _initializeUser() async {
    _userId = Supabase.instance.client.auth.currentUser?.id;
    if (_userId != null) {
      _brandId = await ApiService.getBrandIdForUser(_userId!);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brand Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Create'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Messages'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCreateCampaign(),
          _buildActiveCampaigns(),
          _buildCompletedCampaigns(),
          _buildMessages(),
          _buildAnalytics(),
        ],
      ),
    );
  }

  // TAB 1: CREATE CAMPAIGN
  Widget _buildCreateCampaign() {
    final nameController = TextEditingController();
    final cityController = TextEditingController();
    final weeklyBudgetController = TextEditingController();
    final durationWeeksController = TextEditingController();
    final driverEarningsController = TextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Campaign',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Campaign Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: cityController,
            decoration: const InputDecoration(
              labelText: 'Target City',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: weeklyBudgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Weekly Budget (USD)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: durationWeeksController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Campaign Duration (Weeks)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: driverEarningsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Driver Earnings Per Week (USD)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _createCampaign(
              nameController.text,
              cityController.text,
              weeklyBudgetController.text,
              durationWeeksController.text,
              driverEarningsController.text,
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Create Campaign'),
          ),
        ],
      ),
    );
  }

  void _createCampaign(
    String name,
    String city,
    String weeklyBudget,
    String durationWeeks,
    String driverEarnings,
  ) async {
    if (_brandId == null) return;
    if (name.isEmpty || city.isEmpty || weeklyBudget.isEmpty || durationWeeks.isEmpty || driverEarnings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    final success = await ApiService.createCampaign(
      brandId: _brandId!,
      campaignName: name,
      targetCity: city,
      weeklyBudget: double.parse(weeklyBudget),
      campaignDurationWeeks: int.parse(durationWeeks),
      driverEarningsPerWeek: double.parse(driverEarnings),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Campaign created!')),
      );
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create campaign')),
      );
    }
  }

  // TAB 2: ACTIVE CAMPAIGNS
  Widget _buildActiveCampaigns() {
    if (_brandId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Brand profile not found'),
            const SizedBox(height: 8),
            Text('User ID: $_userId'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _initializeUser(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ApiService.getCampaignsByBrand(_brandId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No active campaigns'));
        }

        // Filter only active campaigns
        final activeCampaigns = snapshot.data!
            .where((c) => c['status'] == 'active' || c['status'] == null)
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeCampaigns.length,
          itemBuilder: (context, index) {
            final campaign = activeCampaigns[index];
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
                    Text('Description: ${campaign['description'] ?? 'N/A'}'),
                    Text('Budget: \$${campaign['budget'] ?? 'N/A'}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _viewAssignments(campaign['id']),
                      child: const Text('View Drivers'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _viewAssignments(String campaignId) async {
    final assignments = await ApiService.getCampaignAssignments(campaignId);
    
    if (!mounted) return;
    
    // Check for error
    if (assignments.isNotEmpty && assignments[0]['error'] == true) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('${assignments[0]['message']}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assigned Drivers'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DEBUG: Campaign ID: $campaignId', 
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text('DEBUG: Assignments count: ${assignments.length}', 
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
                // Check for error responses
                if (assignments.isNotEmpty && assignments[0].containsKey('__error'))
                  ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('⚠️ ERROR', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('${assignments[0]['__message'] ?? 'Unknown error'}', 
                            style: const TextStyle(fontSize: 11, color: Colors.red)),
                          if (assignments[0].containsKey('__type'))
                            Text('Type: ${assignments[0]['__type']}', 
                              style: const TextStyle(fontSize: 9, color: Colors.red)),
                          if (assignments[0].containsKey('__body'))
                            Text('Details: ${assignments[0]['__body']}', 
                              style: const TextStyle(fontSize: 9, color: Colors.red), 
                              maxLines: 3, 
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ]
                else if (assignments.isNotEmpty)
                  Text('DEBUG: First assignment keys: ${assignments[0].keys.toString()}', 
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
                // Display raw API response for debugging
                if (assignments.isNotEmpty && assignments[0].containsKey('__raw_response'))
                  ...[\n                    const SizedBox(height: 8),
                    Container(\n                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(\n                        color: Colors.blue[50],
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(\n                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [\n                          const Text('📡 RAW API RESPONSE:', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue)),
                          Text('Status: ${assignments[0]['__response_status'] ?? '?'}', 
                            style: const TextStyle(fontSize: 9, color: Colors.blue)),
                          const SizedBox(height: 4),
                          Text(\n                            assignments[0]['__raw_response'].toString().substring(0, 300),
                            style: const TextStyle(fontSize: 8, color: Colors.blue, fontFamily: 'Courier'),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                // Display empty response info
                if (assignments.isNotEmpty && assignments[0].containsKey('__empty'))
                  ...[\n                    const SizedBox(height: 8),
                    Container(\n                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(\n                        color: Colors.orange[50],
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(\n                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [\n                          const Text('⚠️ API RETURNED EMPTY ARRAY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.orange)),
                          Text('Status: ${assignments[0]['__response_status'] ?? '?'}', 
                            style: const TextStyle(fontSize: 9, color: Colors.orange)),
                          const SizedBox(height: 4),
                          Text(\n                            'Raw: ' + (assignments[0]['__raw_response'].toString().substring(0, 250)),
                            style: const TextStyle(fontSize: 8, color: Colors.orange, fontFamily: 'Courier'),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                const SizedBox(height: 16),
                if (assignments.isEmpty || (assignments.isNotEmpty && assignments[0].containsKey('__error')))
                  const Text('No drivers assigned yet')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: assignments.length,
                    itemBuilder: (context, index) {
                      final assignment = assignments[index];
                      final driverProfile = assignment['driver_profiles'] as Map<String, dynamic>?;
                      final users = driverProfile?['users'] as Map<String, dynamic>?;
                      final driverName = users?['full_name'] ?? 'Unknown Driver';
                      final driverEmail = users?['email'] ?? '';
                      final status = assignment['status'] ?? 'active';
                      
                      return Column(
                        children: [
                          ListTile(
                            title: Text(driverName),
                            subtitle: Text('$driverEmail • Status: $status'),
                          ),
                          if (index < assignments.length - 1)
                            const Divider(),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // TAB 3: COMPLETED CAMPAIGNS
  Widget _buildCompletedCampaigns() {
    if (_brandId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Brand profile not found'),
            const SizedBox(height: 8),
            Text('User ID: $_userId'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _initializeUser(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ApiService.getCampaignsByBrand(_brandId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No completed campaigns'));
        }

        // Filter only completed campaigns
        final completedCampaigns =
            snapshot.data!.where((c) => c['status'] == 'completed').toList();

        return completedCampaigns.isEmpty
            ? const Center(child: Text('No completed campaigns yet'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: completedCampaigns.length,
                itemBuilder: (context, index) {
                  final campaign = completedCampaigns[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text(campaign['campaign_name'] ?? 'Unknown'),
                      subtitle:
                          Text('Location: ${campaign['target_city'] ?? 'Unknown'}'),
                    ),
                  );
                },
              );
      },
    );
  }

  // TAB 4: MESSAGES
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

  // TAB 5: ANALYTICS
  Widget _buildAnalytics() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Analytics coming soon'),
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
