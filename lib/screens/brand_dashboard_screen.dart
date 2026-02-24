import 'package:flutter/material.dart';
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
  String? _userId;
  String? _brandId;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final userId = await ApiService.getCurrentUserId();
    print('DEBUG: Got userId: $userId');
    
    if (userId != null) {
      final brandId = await ApiService.getBrandIdForUser(userId);
      print('DEBUG: Got brandId: $brandId');
      
      setState(() {
        _userId = userId;
        _brandId = brandId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Brand Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Create Campaign'),
              Tab(text: 'Active Campaigns'),
              Tab(text: 'Completed'),
              Tab(text: 'Analytics'),
              Tab(text: 'Messages'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCreateCampaignTab(),
            _buildActiveCampaignsTab(),
            _buildCompletedTab(),
            _buildAnalyticsTab(),
            _buildMessagesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateCampaignTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _CreateCampaignForm(
        userId: _userId,
        brandId: _brandId,
      ),
    );
  }

  Widget _buildActiveCampaignsTab() {
    if (_brandId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ApiService.getCampaignsByBrand(_brandId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No campaigns created yet'));
        }

        final campaigns = snapshot.data!;
        return ListView.builder(
          itemCount: campaigns.length,
          itemBuilder: (context, index) {
            final campaign = campaigns[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(campaign['campaign_name'] ?? 'Unnamed'),
                subtitle: Text('Budget: \$${campaign['weekly_budget'] ?? 0}/week'),
                trailing: ElevatedButton(
                  onPressed: () => _showAssignmentsDialog(campaign['id']),
                  child: const Text('View Drivers'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAssignmentsDialog(String campaignId) async {
    final assignments = await ApiService.getCampaignAssignments(campaignId);
    
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assigned Drivers'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Assignments found: ${assignments.length}'),
              const SizedBox(height: 16),
              if (assignments.isEmpty)
                const Text('No assigned drivers yet')
              else
                ...assignments.map((a) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Driver: ${a['users']?['full_name'] ?? 'N/A'}'),
                        Text('Status: ${a['status'] ?? 'N/A'}'),
                      ],
                    ),
                  ),
                )),
            ],
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

  Widget _buildCompletedTab() {
    return const Center(child: Text('Completed campaigns will appear here'));
  }

  Widget _buildAnalyticsTab() {
    return const Center(child: Text('Analytics coming soon'));
  }

  Widget _buildMessagesTab() {
    return const Center(child: Text('Messages coming soon'));
  }
}

class _CreateCampaignForm extends StatefulWidget {
  final String? userId;
  final String? brandId;

  const _CreateCampaignForm({
    required this.userId,
    required this.brandId,
  });

  @override
  State<_CreateCampaignForm> createState() => _CreateCampaignFormState();
}

class _CreateCampaignFormState extends State<_CreateCampaignForm> {
  final _formKey = GlobalKey<FormState>();
  String _campaignName = '';
  String _targetCity = '';
  double _weeklyBudget = 0;
  int _duration = 1;
  double _driverEarnings = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (widget.brandId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Campaign Name'),
            validator: (v) => v!.isEmpty ? 'Required' : null,
            onChanged: (v) => _campaignName = v,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Target City'),
            validator: (v) => v!.isEmpty ? 'Required' : null,
            onChanged: (v) => _targetCity = v,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Weekly Budget (\$)'),
            keyboardType: TextInputType.number,
            validator: (v) => v!.isEmpty ? 'Required' : null,
            onChanged: (v) => _weeklyBudget = double.tryParse(v) ?? 0,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Duration (weeks)'),
            keyboardType: TextInputType.number,
            validator: (v) => v!.isEmpty ? 'Required' : null,
            onChanged: (v) => _duration = int.tryParse(v) ?? 1,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Driver Earnings/Week (\$)'),
            keyboardType: TextInputType.number,
            validator: (v) => v!.isEmpty ? 'Required' : null,
            onChanged: (v) => _driverEarnings = double.tryParse(v) ?? 0,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Campaign'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ApiService.createCampaign(
      brandId: widget.brandId!,
      campaignName: _campaignName,
      targetCity: _targetCity,
      weeklyBudget: _weeklyBudget,
      campaignDurationWeeks: _duration,
      driverEarningsPerWeek: _driverEarnings,
    );

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Campaign created successfully')),
      );
      _formKey.currentState!.reset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create campaign')),
      );
    }
  }
}
