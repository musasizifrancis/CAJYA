import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  final supabase = Supabase.instance.client;

  // Sign in with email and password - returns Map with success/error
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return {
        'success': true,
        'user': response.user?.id,
        'email': response.user?.email,
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: $e',
      };
    }
  }

  // Sign up with email and password - returns Map with success/error
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String userRole,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'user_role': userRole,
        },
      );
      return {
        'success': true,
        'user': response.user?.id,
        'email': response.user?.email,
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred: $e',
      };
    }
  }

  // Sign out
  Future<Map<String, dynamic>> signOut() async {
    try {
      await supabase.auth.signOut();
      return {
        'success': true,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Sign out failed: $e',
      };
    }
  }

  // Get current user
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return supabase.auth.currentUser != null;
  }

  // Get current user email
  String? getCurrentUserEmail() {
    return supabase.auth.currentUser?.email;
  }

  // Update user metadata
  Future<Map<String, dynamic>> updateUserMetadata(Map<String, dynamic> metadata) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(
          data: metadata,
        ),
      );
      return {
        'success': true,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Update failed: $e',
      };
    }
  }

  // Password reset
  Future<Map<String, dynamic>> resetPassword({required String email}) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      return {
        'success': true,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Reset failed: $e',
      };
    }
  }
}
