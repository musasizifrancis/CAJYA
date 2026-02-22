import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  static final Supabase _supabase = Supabase.instance;

  // GET CURRENT USER
  static Future<String?> getCurrentUserId() async {
    try {
      return _supabase.client.auth.currentUser?.id;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  static Future<String?> getDriverIdForUser(String userId) async {
    try {
      final response = await _supabase.client
          .from('driver_profiles')
          .select('id')
          .eq('user_id', userId)
          .single();
      return response['id'] as String?;
    } catch (e) {
      print('Error getting driver ID: $e');
      return null;
    }
  }

  static Future<String?> getBrandIdForUser(String userId) async {
    try {
      final response = await _supabase.client
          .from('brand_profiles')
          .select('id')
          .eq('user_id', userId)
          .single();
      return response['id'] as String?;
    } catch (e) {
      print('Error getting brand ID: $e');
      return null;
    }
  }

  // CAMPAIGNS
  static Future<List<Map<String, dynamic>>> getAllCampaigns() async {
    try {
      final response = await _supabase.client.from('campaigns').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getCampaignsByBrand(String brandId) async {
    try {
      final response = await _supabase.client
          .from('campaigns')
          .select()
          .eq('brand_id', brandId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAvailableCampaigns(String driverId) async {
    try {
      final allCampaigns = await _supabase.client.from('campaigns').select();
      final assignedCampaigns = await _supabase.client
          .from('campaign_assignments')
          .select('campaign_id')
          .eq('driver_id', driverId);

      final assignedIds = (assignedCampaigns as List).map((item) => item['campaign_id']).toList();
      final available = (allCampaigns as List).where((c) => !assignedIds.contains(c['id'])).toList();
      return List<Map<String, dynamic>>.from(available);
    } catch (e) {
      return [];
    }
  }

  static Future<bool> createCampaign({
    required String brandId,
    required String campaignName,
    required String targetCity,
    required String description,
    required double budget,
    required int durationDays,
  }) async {
    try {
      await _supabase.client.from('campaigns').insert({
        'brand_id': brandId,
        'campaign_name': campaignName,
        'target_city': targetCity,
        'description': description,
        'budget': budget,
        'duration_days': durationDays,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // CAMPAIGN ASSIGNMENTS
  static Future<List<Map<String, dynamic>>> getDriverCampaigns(String driverId) async {
    try {
      final assignments = await _supabase.client
          .from('campaign_assignments')
          .select('*, campaigns(*)')
          .eq('driver_id', driverId);
      return List<Map<String, dynamic>>.from(assignments);
    } catch (e) {
      return [];
    }
  }

  static Future<bool> applyForCampaign(String driverId, String campaignId) async {
    try {
      await _supabase.client.from('campaign_assignments').insert({
        'driver_id': driverId,
        'campaign_id': campaignId,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getCampaignAssignments(String campaignId) async {
    try {
      final assignments = await _supabase.client
          .from('campaign_assignments')
          .select('*, driver_profile(*)')
          .eq('campaign_id', campaignId);
      return List<Map<String, dynamic>>.from(assignments);
    } catch (e) {
      return [];
    }
  }

  // EARNINGS & WITHDRAWALS
  static Future<double> getTotalEarnings(String driverId) async {
    try {
      final response = await _supabase.client
          .from('withdrawals')
          .select('amount')
          .eq('driver_id', driverId);
      double total = 0;
      for (var item in response) {
        total += (item['amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  static Future<List<Map<String, dynamic>>> getWithdrawalHistory(String driverId) async {
    try {
      final response = await _supabase.client
          .from('withdrawals')
          .select()
          .eq('driver_id', driverId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  static Future<bool> requestWithdrawal({
    required String driverId,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      await _supabase.client.from('withdrawals').insert({
        'driver_id': driverId,
        'amount': amount,
        'payment_method': paymentMethod,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // DRIVER PROFILE
  static Future<Map<String, dynamic>?> getDriverProfile(String driverId) async {
    try {
      final response = await _supabase.client
          .from('driver_profiles')
          .select()
          .eq('id', driverId)
          .single();
      return response as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // BRAND PROFILE
  static Future<Map<String, dynamic>?> getBrandProfile(String brandId) async {
    try {
      final response = await _supabase.client
          .from('brand_profiles')
          .select()
          .eq('id', brandId)
          .single();
      return response as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // DRIVER LOCATION
  static Future<bool> updateDriverLocation({
    required String driverId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _supabase.client.from('driver_locations').insert({
        'driver_id': driverId,
        'latitude': latitude,
        'longitude': longitude,
        'recorded_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
