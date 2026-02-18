import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BrandDashboardScreen extends StatefulWidget {
  final String email;
  final String userRole;

  const BrandDashboardScreen({
    super.key,
    required this.email,
    required this.userRole,
  });

  @override
  State<BrandDashboardScreen> createState() => _BrandDashboardScreenState();
}

class _BrandDashboardScreenState extends State<BrandDashboardScreen> {
  int _selectedTabIndex = 0;
  GoogleMapController? _mapController;

  // Sample drivers data
  final List<Map<String, dynamic>> drivers = [
    {
      'id': 1,
      'name': 'John Doe',
      'location': 'Kampala, Uganda',
      'status': 'Online',
      'latitude': 0.3476,
      'longitude': 32.5825,
    },
    {
      'id': 2,
      'name': 'Jane Smith',
      'location': 'Makindye, Kampala',
      'status': 'Online',
      'latitude': 0.3148,
      'longitude': 32.5850,
    },
    {
      'id': 3,
      'name': 'Mike Johnson',
      'location': 'Kololo, Kampala',
      'status': 'Offline',
      'latitude': 0.3869,
      'longitude': 32.6060,
    },
    {
      'id': 4,
      'name': 'Sarah Williams',
      'location': 'Bukoto, Kampala',
      'status': 'Online',
      'latitude': 0.3597,
      'longitude': 32.6122,
    },
  ];

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brand Dashboard'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: _buildTabContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Drivers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildDriversTab();
      case 2:
        return _buildAnalyticsTab();
      case 3:
        return _buildSettingsTab();
      default:
        return _buildDashboardTab();
    }
  }

  // Dashboard Tab
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campaign Budget Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.blue[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Campaign Budget Spent',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  'UGX 1,250,000',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 0.65,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(Colors.green[400]),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '65% of Budget Used',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Active Campaigns',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildCampaignCard('Campaign A', 'Uber-like Service', 'UGX 50,000/day'),
          const SizedBox(height: 12),
          _buildCampaignCard('Campaign B', 'Premium Rides', 'UGX 75,000/day'),
          const SizedBox(height: 12),
          _buildCampaignCard('Campaign C', 'Express Delivery', 'UGX 60,000/day'),
        ],
      ),
    );
  }

  // Drivers Tab with Map
  Widget _buildDriversTab() {
    return Stack(
      children: [
        // Google Map
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(0.3476, 32.5825),
            zoom: 12,
          ),
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          markers: _buildDriverMarkers(),
        ),
        // Drivers List Overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                )
              ],
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              scrollDirection: Axis.horizontal,
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                final driver = drivers[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        driver['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        driver['location'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 2,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: driver['status'] == 'Online'
                              ? Colors.green[100]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          driver['status'],
                          style: TextStyle(
                            color: driver['status'] == 'Online'
                                ? Colors.green[800]
                                : Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Build Driver Markers
  Set<Marker> _buildDriverMarkers() {
    return drivers
        .map(
          (driver) => Marker(
            markerId: MarkerId(driver['id'].toString()),
            position: LatLng(driver['latitude'], driver['longitude']),
            infoWindow: InfoWindow(
              title: driver['name'],
              snippet: driver['location'],
            ),
          ),
        )
        .toSet();
  }

  // Analytics Tab
  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Metrics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildMetricCard('Total Impressions', '125,430', Colors.blue),
          const SizedBox(height: 12),
          _buildMetricCard('Click-Through Rate', '8.5%', Colors.green),
          const SizedBox(height: 12),
          _buildMetricCard('Conversions', '342', Colors.orange),
          const SizedBox(height: 12),
          _buildMetricCard('Avg. Driver Rating', '4.8/5', Colors.purple),
          const SizedBox(height: 24),
          const Text(
            'Engagement Trends',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Chart showing engagement trends over time',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Settings Tab
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ListTile(
          title: const Text('Profile'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          title: const Text('Payment Methods'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          title: const Text('Help & Support'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {},
        ),
        const Divider(),
        ListTile(
          title: const Text('Sign Out'),
          titleTextStyle: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          trailing: const Icon(Icons.logout, color: Colors.red),
          onTap: () {
            // Sign out logic
          },
        ),
      ],
    );
  }

  // Helper method to build campaign card
  Widget _buildCampaignCard(String title, String subtitle, String price) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.campaign, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build metric card
  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}