import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late SupabaseClient _client;

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  SupabaseClient get client => _client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://nrwfehkdvaujcypvddhq.supabase.co',
      anonKey: 'sb_publishable_F7T3fQPmz6Zq1bFK25W4XQ_UP8ulQqG',
    );
    _instance._client = Supabase.instance.client;
  }

  // SIGN UP
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String userRole,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        await _client.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'user_role': userRole,
          'full_name': fullName,
        });
        return {'success': true, 'user_id': response.user!.id};
      }
      return {'success': false, 'message': 'Failed to create user'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // SIGN IN
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        final userProfile = await _client
            .from('users')
            .select()
            .eq('id', response.user!.id)
            .single();
        return {
          'success': true,
          'user_id': response.user!.id,
          'user_role': userProfile['user_role'],
        };
      }
      return {'success': false};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // CREATE CAMPAIGN
  Future<Map<String, dynamic>> createCampaign({
    required String brandId,
    required String campaignName,
    required String targetCity,
    required double weeklyBudget,
    required int campaignDurationWeeks,
    required int driversNeeded,
  }) async {
    try {
      final response = await _client.from('campaigns').insert({
        'brand_id': brandId,
        'campaign_name': campaignName,
        'target_city': targetCity,
        'weekly_budget': weeklyBudget,
        'campaign_duration_weeks': campaignDurationWeeks,
        'drivers_needed': driversNeeded,
        'status': 'active',
      }).select();

      return {'success': true, 'campaign_id': response[0]['id']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // GET BRAND CAMPAIGNS
  Future<List<Map<String, dynamic>>> getBrandCampaigns(String brandId) async {
    try {
      final response = await _client
          .from('campaigns')
          .select()
          .eq('brand_id', brandId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}