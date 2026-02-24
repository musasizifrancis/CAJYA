import 'package:flutter/material.dart';
import 'package:cajya/services/api_service.dart';

class BrandDashboardScreen extends StatefulWidget {
  final String userEmail;
  final String userId;
  final String brandName;

  const BrandDashboardScreen({
    required this.userEmail,
    required this.userId,
    required this.brandName,
  });

  @override
  State<BrandDashboardScreen> createState() => _BrandDashboardScreenState();
}

class _BrandDashboardScreenState extends State<BrandDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.brandName} Dashboard'),
        backgroundColor: Colors.blue[700],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Create Campaign'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle), label: 'Active Campaigns'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Completed'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: return _buildCreateCampaignTab();
      case 1: return _buildActiveCampaignsTab();
      case 2: return _buildCompletedCampaignsTab();
      case 3: return _buildMessagesTab();
      case 4: return _buildAnalyticsTab();
      default: return const SizedBox.shrink();
    }
  }

  // CREATE CAMPAIGN TAB
  Widget _buildCreateCampaignTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: CreateCampaignForm(userId: widget.userId),
    );
  }

  // ACTIVE CAMPAIGNS TAB
  Widget _buildActiveCampaignsTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ApiService().getActiveCampaigns(widget.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final campaigns = snapshot.data!;
        if (campaigns.isEmpty) return const Center(child: Text('No active campaigns'));
        
        return ListView.builder(
          itemCount: campaigns.length,
          itemBuilder: (context, index) {
            final campaign = campaigns[index];
            return CampaignCard(
              campaign: campaign,
              onViewDrivers: () => _showAssignmentsDialog(campaign),
            );
          },
        );
      },
    );
  }

  void _showAssignmentsDialog(Map<String, dynamic> campaign) async {
    final campaignId = campaign['id'] as String;
    final assignments = await ApiService().getCampaignAssignments(campaignId);
    
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Drivers - ${campaign['campaign_name']}'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Campaign ID: $campaignId', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text('Assignments found: ${assignments.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                if (assignments.isEmpty)
                  const SizedBox(height: 20)
                else
                  Column(
                    children: assignments.map<Widget>((a) {
                      return Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Driver: ${a['driver_profiles']?['users']?['full_name'] ?? 'Unknown'}'),
                            Text('Email: ${a['driver_profiles']?['users']?['email'] ?? 'N/A'}', style: const TextStyle(fontSize: 10)),
                            Text('Status: ${a['status']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                if (assignments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text('No drivers assigned yet', style: TextStyle(color: Colors.grey)),
                  ),
              ],
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildCompletedCampaignsTab() {
    return const Center(child: Text('Completed campaigns coming soon'));
  }

  Widget _buildMessagesTab() {
    return const Center(child: Text('Messages coming soon'));
  }

  Widget _buildAnalyticsTab() {
    return const Center(child: Text('Analytics coming soon'));
  }
}

// CAMPAIGN CARD
class CampaignCard extends StatelessWidget {
  final Map<String, dynamic> campaign;
  final VoidCallback onViewDrivers;

  const CampaignCard({required this.campaign, required this.onViewDrivers});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        title: Text(campaign['campaign_name'] ?? 'Unknown'),
        subtitle: Text('Budget: \\$${campaign['weekly_budget'] ?? 0}/week'),
        trailing: ElevatedButton(
          onPressed: onViewDrivers,
          child: const Text('View Drivers'),
        ),
      ),
    );
  }
}

// CREATE CAMPAIGN FORM
class CreateCampaignForm extends StatefulWidget {
  final String userId;
  const CreateCampaignForm({required this.userId});

  @override
  State<CreateCampaignForm> createState() => _CreateCampaignFormState();
}

class _CreateCampaignFormState extends State<CreateCampaignForm> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _budgetController = TextEditingController();
  final _durationController = TextEditingController();
  final _earningsController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Campaign Name')),
        const SizedBox(height: 12),
        TextField(controller: _cityController, decoration: const InputDecoration(labelText: 'Target City')),
        const SizedBox(height: 12),
        TextField(controller: _budgetController, decoration: const InputDecoration(labelText: 'Weekly Budget (USD)'), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(controller: _durationController, decoration: const InputDecoration(labelText: 'Duration (weeks)'), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(controller: _earningsController, decoration: const InputDecoration(labelText: 'Driver Earnings/Week (USD)'), keyboardType: TextInputType.number),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _createCampaign,
          child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Create Campaign'),
        ),
      ],
    );
  }

  Future<void> _createCampaign() async {
    setState(() => _isLoading = true);
    try {
      await ApiService().createCampaign(
        brandId: widget.userId,
        campaignName: _nameController.text,
        targetCity: _cityController.text,
        weeklyBudget: double.parse(_budgetController.text),
        campaignDurationWeeks: int.parse(_durationController.text),
        driverEarningsPerWeek: double.parse(_earningsController.text),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Campaign created!')));
        _nameController.clear();
        _cityController.clear();
        _budgetController.clear();
        _durationController.clear();
        _earningsController.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _budgetController.dispose();
    _durationController.dispose();
    _earningsController.dispose();
    super.dispose();
  }
}
