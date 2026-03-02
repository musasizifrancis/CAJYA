import 'package:supabase_flutter/supabase_flutter.dart';

class AdminService {
  static final _client = Supabase.instance.client;

  // ============ DOCUMENT VERIFICATION METHODS ============

  /// Get all pending documents for verification
  static Future<List<Map<String, dynamic>>> getPendingDocuments({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('driver_documents')
          .select('*, driver_profiles(id, user_id, national_id)')
          .eq('verification_status', 'pending')
          .range(offset, offset + limit - 1)
          .order('created_at', ascending: true);
      
      // Fetch driver names from auth.users for each document
      List<Map<String, dynamic>> result = [];
      for (var doc in response) {
        final driverProfile = doc['driver_profiles'] as Map<String, dynamic>?;
        if (driverProfile != null) {
          final userId = driverProfile['user_id'];
          if (userId != null) {
            try {
              final userResponse = await _client
                  .from('auth.users')
                  .select('email')
                  .eq('id', userId)
                  .single();
              
              // Add driver name (from email) to the profile
              doc['driver_profiles']['full_name'] = (userResponse['email'] as String?)?.split('@').first ?? 'Unknown';
            } catch (e) {
              doc['driver_profiles']['full_name'] = 'Unknown Driver';
            }
          }
        }
        result.add(doc);
      }
      
      return result;
    } catch (e) {
      print('Error fetching pending documents: \$e');
      rethrow;
    }
  }

  /// Get all documents for a specific driver
  static Future<List<Map<String, dynamic>>> getDriverDocumentsForAdmin(
    String driverId,
  ) async {
    try {
      final response = await _client
          .from('driver_documents')
          .select()
          .eq('driver_id', driverId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching driver documents: \$e');
      rethrow;
    }
  }

  /// Approve a document
  static Future<bool> approveDocument({
    required String documentId,
    required String verifiedBy,
  }) async {
    try {
      await _client
          .from('driver_documents')
          .update({
            'verification_status': 'approved',
            'verified_by': verifiedBy,
            'verified_at': DateTime.now().toIso8601String(),
          })
          .eq('id', documentId);
      return true;
    } catch (e) {
      print('Error approving document: \$e');
      rethrow;
    }
  }

  /// Reject a document with reason
  static Future<bool> rejectDocument({
    required String documentId,
    required String rejectionReason,
    required String rejectedBy,
  }) async {
    try {
      await _client
          .from('driver_documents')
          .update({
            'verification_status': 'rejected',
            'rejection_reason': rejectionReason,
            'verified_by': rejectedBy,
            'verified_at': DateTime.now().toIso8601String(),
          })
          .eq('id', documentId);
      return true;
    } catch (e) {
      print('Error rejecting document: \$e');
      rethrow;
    }
  }

  /// Get document verification statistics
  static Future<Map<String, int>> getVerificationStats() async {
    try {
      final pending = await _client
          .from('driver_documents')
          .select()
          .eq('verification_status', 'pending');

      final approved = await _client
          .from('driver_documents')
          .select()
          .eq('verification_status', 'approved');

      final rejected = await _client
          .from('driver_documents')
          .select()
          .eq('verification_status', 'rejected');

      return {
        'pending': (pending as List).length,
        'approved': (approved as List).length,
        'rejected': (rejected as List).length,
      };
    } catch (e) {
      print('Error fetching verification stats: \$e');
      return {'pending': 0, 'approved': 0, 'rejected': 0};
    }
  }

  // ============ DRIVER MANAGEMENT METHODS ============

  /// Get all drivers with their profile status
  static Future<List<Map<String, dynamic>>> getAllDrivers({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('driver_profiles')
          .select()
          .range(offset, offset + limit - 1)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching all drivers: \$e');
      rethrow;
    }
  }

  /// Get driver details including documents
  static Future<Map<String, dynamic>?> getDriverDetails(String driverId) async {
    try {
      final response = await _client
          .from('driver_profiles')
          .select('*, driver_documents(*)')
          .eq('id', driverId)
          .single();
      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching driver details: \$e');
      return null;
    }
  }

  /// Search drivers by name or email
  static Future<List<Map<String, dynamic>>> searchDrivers(String query) async {
    try {
      // Search by national ID
      final idResults = await _client
          .from('driver_profiles')
          .select()
          .ilike('national_id', '%\$query%');

      // Search by license number
      final licenseResults = await _client
          .from('driver_profiles')
          .select()
          .ilike('license_number', '%\$query%');

      // Combine and deduplicate
      final combined = [...idResults, ...licenseResults];
      final seen = <String>{};
      final deduped = <Map<String, dynamic>>[];

      for (final item in combined) {
        final id = item['id'] as String;
        if (seen.add(id)) {
          deduped.add(item as Map<String, dynamic>);
        }
      }

      return deduped;
    } catch (e) {
      print('Error searching drivers: \$e');
      rethrow;
    }
  }

  /// Get driver statistics
  static Future<Map<String, dynamic>> getDriverStatistics() async {
    try {
      final allDrivers = await _client.from('driver_profiles').select('id');

      final verified = await _client
          .from('driver_profiles')
          .select()
          .eq('verification_status', 'verified');

      final pending = await _client
          .from('driver_profiles')
          .select()
          .eq('verification_status', 'pending');

      return {
        'totalDrivers': (allDrivers as List).length,
        'verifiedDrivers': (verified as List).length,
        'pendingVerification': (pending as List).length,
      };
    } catch (e) {
      print('Error fetching driver statistics: \$e');
      return {
        'totalDrivers': 0,
        'verifiedDrivers': 0,
        'pendingVerification': 0,
      };
    }
  }

  // ============ NOTIFICATION METHODS ============

  /// Send notification to driver
  static Future<bool> sendNotificationToDriver({
    required String driverId,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _client.from('driver_notifications').insert({
        'driver_id': driverId,
        'title': title,
        'message': message,
        'metadata': metadata,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error sending notification: \$e');
      rethrow;
    }
  }

  /// Send bulk notifications
  static Future<int> sendBulkNotifications({
    required List<String> driverIds,
    required String title,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      int count = 0;
      for (final driverId in driverIds) {
        await sendNotificationToDriver(
          driverId: driverId,
          title: title,
          message: message,
          metadata: metadata,
        );
        count++;
      }
      return count;
    } catch (e) {
      print('Error sending bulk notifications: \$e');
      rethrow;
    }
  }

  /// Get unread notifications for admin
  static Future<List<Map<String, dynamic>>> getAdminNotifications() async {
    try {
      final response = await _client
          .from('admin_notifications')
          .select()
          .eq('is_read', false)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching admin notifications: \$e');
      return [];
    }
  }

  // ============ UTILITY METHODS ============

  /// Export document verification data
  static Future<List<Map<String, dynamic>>> exportVerificationData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _client
          .from('driver_documents')
          .select()
          .gte('verified_at', startDate.toIso8601String())
          .lte('verified_at', endDate.toIso8601String());
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error exporting verification data: \$e');
      rethrow;
    }
  }

  /// Get admin audit log
  static Future<List<Map<String, dynamic>>> getAuditLog({
    int limit = 100,
  }) async {
    try {
      final response = await _client
          .from('admin_audit_log')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching audit log: \$e');
      return [];
    }
  }
}
