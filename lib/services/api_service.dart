import 'dart:io';
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
      
      print('DEBUG: Making HTTP GET to: $url');
      print('DEBUG: Using API Key: ${SUPABASE_KEY.substring(0, 20)}...');
      
      final response = await http.get(
        url,
        headers: {
          'apikey': SUPABASE_KEY,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('ERROR: HTTP request timed out after 10 seconds');
          return http.Response('{"error":"timeout"}', 408);
        }
      );
      
      print('DEBUG: API Response Status: ${response.statusCode}');
      print('DEBUG: API Response Length: ${response.body.length}');
      print('DEBUG: API Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
      
      if (response.statusCode != 200) {
        print('ERROR: API returned ${response.statusCode}: ${response.body}');
        return [{'__error': true, '__message': 'API Error ${response.statusCode}', '__body': response.body.substring(0, 200)}];
      }
      
      // CRITICAL DEBUG: Include raw response in result
      final assignments = jsonDecode(response.body) as List;
      print('DEBUG: Raw assignments count: ${assignments.length}');
      
      // Add debug info to first result so UI can display it
      if (assignments.isNotEmpty) {
        assignments[0]['__raw_response'] = response.body;
        assignments[0]['__response_status'] = response.statusCode;
      } else {
        // Return empty array but with debug info
        return [{'__empty': true, '__raw_response': response.body, '__response_status': response.statusCode}];
      }
      
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
                  // CRITICAL: Nest users inside driver_profiles so UI can find it
                  assignmentMap['driver_profiles']['users'] = users[0];
                  print('DEBUG: Nested users inside driver_profiles successfully');
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
      return [{'__error': true, '__message': 'Error: $e', '__type': e.runtimeType.toString()}];
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


  // ============================================================================
  // PROFILE SETUP METHODS (Phase 2 Implementation)
  // ============================================================================

  /// Method 1: Complete Driver Profile
  /// Save driver profile data after setup
  static Future<bool> completeDriverProfile(
    String driverId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      await _supabase.client
          .from('driver_profiles')
          .update({
            ...profileData,
            'profile_setup_completed': true,
            'profile_completed_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', driverId);

      return true;
    } catch (e) {
      print('Error completing profile: $e');
      rethrow;
    }
  }

  /// Method 2: Upload Document to Storage
  /// Upload a document file to Supabase Storage
  static Future<String> uploadDriverDocument(
    String driverId,
    File file,
    String documentType,
  ) async {
    try {
      // Validate file size (max 10MB)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('File size exceeds 10MB limit');
      }

      // Validate file type
      final fileName = file.path.split('/').last.toLowerCase();
      final extension = fileName.split('.').last;
      if (!['jpg', 'jpeg', 'png', 'pdf'].contains(extension)) {
        throw Exception('Invalid file type. Supported: JPG, PNG, PDF');
      }

      // Upload to Supabase Storage
      final storagePath =
          'driver-documents/$driverId/$documentType/${DateTime.now().millisecondsSinceEpoch}.$extension';

      await _supabase.client.storage.from('driver-documents').upload(storagePath, file);

      // Get public URL
      final publicUrl =
          _supabase.client.storage.from('driver-documents').getPublicUrl(storagePath);

      // Save metadata to driver_documents table
      await _supabase.client.from('driver_documents').insert({
        'driver_id': driverId,
        'document_type': documentType,
        'file_url': publicUrl,
        'file_size_bytes': fileSize,
        'file_mime_type': _getMimeType(extension),
        'created_at': DateTime.now().toIso8601String(),
      });

      return publicUrl;
    } catch (e) {
      print('Error uploading document: $e');
      rethrow;
    }
  }

  /// Helper: Get MIME type from file extension
  static String _getMimeType(String extension) {
    const mimeTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'pdf': 'application/pdf',
    };
    return mimeTypes[extension.toLowerCase()] ?? 'application/octet-stream';
  }

  /// Method 3: Get Driver Profile Status
  /// Get current driver profile completion status
  static Future<Map<String, dynamic>> getDriverProfileStatus(
    String driverId,
  ) async {
    try {
      final response = await _supabase.client
          .from('driver_profiles')
          .select()
          .eq('id', driverId)
          .single();

      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error getting profile status: $e');
      rethrow;
    }
  }

  /// Method 4: Check if Profile Setup is Complete
  /// Quick check if driver has completed profile setup
  static Future<bool> isProfileSetupComplete(String driverId) async {
    try {
      final response = await _supabase.client
          .from('driver_profiles')
          .select('profile_setup_completed')
          .eq('id', driverId)
          .single();

      return response['profile_setup_completed'] as bool? ?? false;
    } catch (e) {
      print('Error checking profile setup: $e');
      return false;
    }
  }

  /// Method 5: Get Driver Documents
  /// Get all documents for a driver
  static Future<List<Map<String, dynamic>>> getDriverDocuments(
    String driverId,
  ) async {
    try {
      final response = await _supabase.client
          .from('driver_documents')
          .select()
          .eq('driver_id', driverId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting documents: $e');
      rethrow;
    }
  }

  /// Method 6: Submit Profile for Verification
  /// Submit driver profile for admin verification
  static Future<String> submitProfileForVerification(String driverId) async {
    try {
      // Create entry in verification queue
      final response = await _supabase.client
          .from('admin_verification_queue')
          .insert({
            'driver_id': driverId,
            'status': 'pending',
            'submitted_at': DateTime.now().toIso8601String(),
            'priority': 0,
          })
          .select('id')
          .single();

      // Update driver profile verification status
      await _supabase.client
          .from('driver_profiles')
          .update({'verification_status': 'pending'})
          .eq('id', driverId);

      return response['id'] as String;
    } catch (e) {
      print('Error submitting for verification: $e');
      rethrow;
    }
  }

  /// Method 7: Get Verification Status
  /// Get the current verification status of a driver's profile
  static Future<String> getVerificationStatus(String driverId) async {
    try {
      final response = await _supabase.client
          .from('driver_profiles')
          .select('verification_status')
          .eq('id', driverId)
          .single();

      return response['verification_status'] as String? ?? 'unknown';
    } catch (e) {
      print('Error getting verification status: $e');
      return 'unknown';
    }
  }

  /// Method 8: Delete Document
  /// Delete a document (for updates/corrections)
  static Future<bool> deleteDriverDocument(String documentId) async {
    try {
      await _supabase.client
          .from('driver_documents')
          .delete()
          .eq('id', documentId);

      return true;
    } catch (e) {
      print('Error deleting document: $e');
      return false;
    }
  }

  /// Method 9: Update Payment Method
  /// Save or update MTN Mobile Money payment details
  static Future<String> updatePaymentMethod(
    String driverId,
    String mtnNumber,
    String accountName,
  ) async {
    try {
      // Check if payment method exists for this driver
      final existing = await _supabase.client
          .from('payment_methods')
          .select('id')
          .eq('driver_id', driverId)
          .eq('payment_provider', 'mtn_mobile_money');

      if (existing.isEmpty) {
        // Insert new payment method
        final response = await _supabase.client
            .from('payment_methods')
            .insert({
              'driver_id': driverId,
              'payment_provider': 'mtn_mobile_money',
              'provider_account_id': mtnNumber,
              'phone_number': mtnNumber,
              'account_name': accountName,
              'status': 'unverified',
              'is_primary': true,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select('id')
            .single();

        return response['id'] as String;
      } else {
        // Update existing payment method
        await _supabase.client
            .from('payment_methods')
            .update({
              'provider_account_id': mtnNumber,
              'phone_number': mtnNumber,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('driver_id', driverId)
            .eq('payment_provider', 'mtn_mobile_money');

        return existing[0]['id'] as String;
      }
    } catch (e) {
      print('Error updating payment method: $e');
      rethrow;
    }
  }

  /// Method 10: Validate License Plate Uniqueness
  /// Check if license plate is already registered
  static Future<bool> isLicensePlateAvailable(String licensePlate) async {
    try {
      final response = await _supabase.client
          .from('driver_profiles')
          .select('id')
          .eq('license_plate', licensePlate);

      return response.isEmpty;
    } catch (e) {
      print('Error checking license plate: $e');
      return false;
    }
  }


  // ============ PROFILE MANAGEMENT METHODS ============
  
  static Future<bool> updatePersonalInfo({
    required String userId,
    required String fullName,
    required String dateOfBirth,
    required String phoneNumber,
    required String emergencyContact,
  }) async {
    try {
      await _client
          .from('driver_profiles')
          .update({
            'full_name': fullName,
            'date_of_birth': dateOfBirth,
            'phone_number': phoneNumber,
            'emergency_contact': emergencyContact,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      return true;
    } catch (e) {
      print('Error updating personal info: \$e');
      rethrow;
    }
  }

  static Future<bool> updateVehicleInfo({
    required String userId,
    required String vehicleMake,
    required String vehicleModel,
    required int vehicleYear,
    required String vehicleLicensePlate,
    required String vehicleColor,
    required String vehicleTransmission,
  }) async {
    try {
      await _client
          .from('driver_profiles')
          .update({
            'vehicle_make': vehicleMake,
            'vehicle_model': vehicleModel,
            'vehicle_year': vehicleYear,
            'vehicle_license_plate': vehicleLicensePlate,
            'vehicle_color': vehicleColor,
            'vehicle_transmission': vehicleTransmission,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      return true;
    } catch (e) {
      print('Error updating vehicle info: \$e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getDocumentDetails(String documentId) async {
    try {
      final response = await _client
          .from('driver_documents')
          .select()
          .eq('id', documentId)
          .single();
      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching document details: \$e');
      rethrow;
    }
  }

  static Future<bool> deleteDocument(String documentId) async {
    try {
      await _client
          .from('driver_documents')
          .delete()
          .eq('id', documentId);
      return true;
    } catch (e) {
      print('Error deleting document: \$e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getDriverNotifications(String driverId) async {
    try {
      final response = await _client
          .from('driver_notifications')
          .select()
          .eq('driver_id', driverId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching notifications: \$e');
      rethrow;
    }
  }

  static Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _client
          .from('driver_notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
      return true;
    } catch (e) {
      print('Error marking notification as read: \$e');
      rethrow;
    }
  }

  static Future<bool> deleteNotification(String notificationId) async {
    try {
      await _client
          .from('driver_notifications')
          .delete()
          .eq('id', notificationId);
      return true;
    } catch (e) {
      print('Error deleting notification: \$e');
      rethrow;
    }
  }

  static Future<int> getUnreadNotificationCount(String driverId) async {
    try {
      final response = await _client
          .from('driver_notifications')
          .select()
          .eq('driver_id', driverId)
          .eq('is_read', false);
      return (response as List).length;
    } catch (e) {
      print('Error fetching unread count: \$e');
      return 0;
    }
  }

  static Future<double> getProfileCompleteness(String userId) async {
    try {
      final profile = await getDriverProfile(userId);
      
      // Define required fields for a complete profile
      final requiredFields = [
        'full_name',
        'date_of_birth',
        'phone_number',
        'id_number',
        'vehicle_make',
        'vehicle_model',
        'vehicle_year',
        'vehicle_license_plate',
        'vehicle_color',
        'vehicle_transmission',
      ];
      
      int completedFields = 0;
      for (final field in requiredFields) {
        if (profile != null && profile[field] != null && profile[field].toString().isNotEmpty) {
          completedFields++;
        }
      }
      
      return (completedFields / requiredFields.length) * 100;
    } catch (e) {
      print('Error calculating profile completeness: \$e');
      return 0.0;
    }
  }
}
