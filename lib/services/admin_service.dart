import 'package:supabase_flutter/supabase_flutter.dart';

class AdminService {
  static final _client = Supabase.instance.client;

  /// Get verification statistics for all documents
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
      print('Error fetching verification stats: $e');
      return {'pending': 0, 'approved': 0, 'rejected': 0};
    }
  }

  /// Get all pending documents for verification (SIMPLIFIED - no auth.users access)
  static Future<List<Map<String, dynamic>>> getPendingDocuments({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('driver_documents')
          .select('*, driver_profiles(id, user_id)')
          .eq('verification_status', 'pending')
          .range(offset, offset + limit - 1)
          .order('created_at', ascending: false);
      
      // Convert response to list and add dummy driver names
      List<Map<String, dynamic>> result = [];
      for (var doc in response) {
        final driverProfile = doc['driver_profiles'] as Map<String, dynamic>?;
        if (driverProfile != null) {
          // Add a placeholder driver name
          doc['driver_profiles']['full_name'] = 'Driver #${driverProfile['id']?.toString().substring(0, 8) ?? "Unknown"}';
        }
        result.add(doc);
      }
      
      return result;
    } catch (e) {
      print('Error fetching pending documents: $e');
      rethrow;
    }
  }

  /// Get all approved documents
  static Future<List<Map<String, dynamic>>> getApprovedDocuments({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('driver_documents')
          .select('*, driver_profiles(id, user_id)')
          .eq('verification_status', 'approved')
          .range(offset, offset + limit - 1)
          .order('verified_at', ascending: false);
      
      List<Map<String, dynamic>> result = [];
      for (var doc in response) {
        final driverProfile = doc['driver_profiles'] as Map<String, dynamic>?;
        if (driverProfile != null) {
          doc['driver_profiles']['full_name'] = 'Driver #${driverProfile['id']?.toString().substring(0, 8) ?? "Unknown"}';
        }
        result.add(doc);
      }
      
      return result;
    } catch (e) {
      print('Error fetching approved documents: $e');
      rethrow;
    }
  }

  /// Get all rejected documents
  static Future<List<Map<String, dynamic>>> getRejectedDocuments({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('driver_documents')
          .select('*, driver_profiles(id, user_id)')
          .eq('verification_status', 'rejected')
          .range(offset, offset + limit - 1)
          .order('verified_at', ascending: false);
      
      List<Map<String, dynamic>> result = [];
      for (var doc in response) {
        final driverProfile = doc['driver_profiles'] as Map<String, dynamic>?;
        if (driverProfile != null) {
          doc['driver_profiles']['full_name'] = 'Driver #${driverProfile['id']?.toString().substring(0, 8) ?? "Unknown"}';
        }
        result.add(doc);
      }
      
      return result;
    } catch (e) {
      print('Error fetching rejected documents: $e');
      rethrow;
    }
  }

  /// Get a single document for detailed review
  static Future<Map<String, dynamic>?> getDocumentDetails(String docId) async {
    try {
      return await _client
          .from('driver_documents')
          .select('*, driver_profiles(id, user_id)')
          .eq('id', docId)
          .single();
    } catch (e) {
      print('Error fetching document details: $e');
      return null;
    }
  }

  /// Approve a document
  static Future<void> approveDocument({
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
            'rejection_reason': null,
          })
          .eq('id', documentId);
    } catch (e) {
      print('Error approving document: $e');
      rethrow;
    }
  }

  /// Reject a document with reason
  static Future<void> rejectDocument({
    required String documentId,
    required String verifiedBy,
    required String rejectionReason,
  }) async {
    try {
      await _client
          .from('driver_documents')
          .update({
            'verification_status': 'rejected',
            'verified_by': verifiedBy,
            'verified_at': DateTime.now().toIso8601String(),
            'rejection_reason': rejectionReason,
          })
          .eq('id', documentId);
    } catch (e) {
      print('Error rejecting document: $e');
      rethrow;
    }
  }
}
