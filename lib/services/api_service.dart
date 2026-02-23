import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static final Supabase _supabase = Supabase.instance;
  static const String SUPABASE_URL = 'https://nrwfehkdvaujcypvddhq.supabase.co';
  static const String SUPABASE_KEY = 'sb_publishable_F7T3fQPmz6Zq1bFK25W4XQ_UP8ulQqG';

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
      print('DEBUG: Getting driver ID for user: $userId');
      final response = await _supabase.client
          .from('driver_profiles')
          .select('id')
          .eq('user_id', userId);
      
      print('DEBUG: Driver profile response: $response');
      
      if (response.isEmpty) {
        print('ERROR: No driver profile found for user $userId');
        return null;
      }
      
      return response[0]['id'] as String?;
    } catch (e) {
      print('ERROR getting driver ID: $e');
      return null;
    }
  }

  static Future<String?> getBrandIdForUser(String userId) async {
    try {
      print('DEBUG: Getting brand ID for user: $userId');
      final response = await _supabase.client
          .from('brand_profiles')
          .select('id')
          .eq('user_id', userId);
      
      print('DEBUG: Brand profile response: $response');
      
      if (response.isEmpty) {
        print('ERROR: No brand profile found for user $userId');
        return null;
      }
      
      return response[0]['id'] as String?;
    } catch (e) {
      print('ERROR getting brand ID: $e');
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
    required double weeklyBudget,
    required int campaignDurationWeeks,
    required double driverEarningsPerWeek,
  }) async {
    try {
      await _supabase.client.from('campaigns').insert({
        'brand_id': brandId,
        'campaign_name': campaignName,
        'target_city': targetCity,
        'weekly_budget': weeklyBudget,
        'campaign_duration_weeks': campaignDurationWeeks,
        'driver_earnings_per_week': driverEarningsPerWeek,
      });
      return true;
    } catch (e) {
      print('Error creating campaign: $e');
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
      print('DEBUG: Applying for campaign...');
      print('Driver ID: $driverId');
      print('Campaign ID: $campaignId');
      
      await _supabase.client.from('campaign_assignments').insert({
        'driver_id': driverId,
        'campaign_id': campaignId,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      });
      
      print('DEBUG: Apply successful!');
      return true;
    } catch (e) {
      print('ERROR applying for campaign: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getCampaignAssignments(String campaignId) async {
    try {
      print('DEBUG: Fetching assignments for campaign: $campaignId');
      
      // Use REST API directly - it's more reliable than Flutter SDK
      final url = Uri.parse(
        '$SUPABASE_URL/rest/v1/campaign_assignments?campaign_id=eq.$campaignId'
      );
      
      final response = await http.get(
        url,
        headers: {
          'apikey': SUPABASE_KEY,
          'Content-Type': 'application/json',
        },
      );
      
      print('DEBUG: API Response Status: ${response.statusCode}');
      print('DEBUG: API Response Body: ${response.body}');
      
      if (response.statusCode != 200) {
        print('ERROR: API returned ${response.statusCode}');
        return [{'error': true, 'message': 'API Error: ${response.statusCode}'}];
      }
      
      final assignments = jsonDecode(response.body) as List;
      print('DEBUG: Raw assignments count: ${assignments.length}');
      
      if (assignments.isEmpty) {
        print('DEBUG: No assignments found for this campaign');
        return [];
      }
      
      // Now fetch driver details for each assignment
      List<Map<String, dynamic>> enrichedAssignments = [];
      for (var assignment in assignments) {
        try {
          final assignmentMap = assignment as Map<String, dynamic>;
          final driverId = assignmentMap['driver_id'];
          print('DEBUG: Fetching driver details for driver_id: $driverId');
          
          // Get driver profile
          final driverUrl = Uri.parse(
            '$SUPABASE_URL/rest/v1/driver_profiles?id=eq.$driverId'
          );
          final driverResp = await http.get(
            driverUrl,
            headers: {
              'apikey': SUPABASE_KEY,
              'Content-Type': 'application/json',
            },
          );
          
          if (driverResp.statusCode == 200) {
            final driverProfiles = jsonDecode(driverResp.body) as List;
            if (driverProfiles.isNotEmpty) {
              final driverProfile = driverProfiles[0] as Map<String, dynamic>;
              final userId = driverProfile['user_id'];
              
              // Get user details
              final userUrl = Uri.parse(
                '$SUPABASE_URL/rest/v1/users?id=eq.$userId'
              );
              final userResp = await http.get(
                userUrl,
                headers: {
                  'apikey': SUPABASE_KEY,
                  'Content-Type': 'application/json',
                },
              );
              
              if (userResp.statusCode == 200) {
                final users = jsonDecode(userResp.body) as List;
                if (users.isNotEmpty) {
                  assignmentMap['driver_profiles'] = driverProfile;
                  assignmentMap['users'] = users[0];
                }
              }
            }
          }
          enrichedAssignments.add(assignmentMap);
        } catch (e) {
          print('ERROR enriching assignment: $e');
          enrichedAssignments.add(assignment as Map<String, dynamic>);
        }
      }
      
      print('DEBUG: Returning ${enrichedAssignments.length} enriched assignments');
      return enrichedAssignments;
    } catch (e, stackTrace) {
      print('ERROR getting assignments: $e');
      print('ERROR stack: $stackTrace');
      // Return error info so UI can show it
      return [{'error': true, 'message': 'Error loading assignments: $e'}];
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
