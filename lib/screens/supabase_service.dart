mport 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  /// Sign in with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return {
          'success': true,
          'user': response.user,
          'email': email,
        };
      }
      return {
        'success': false,
        'error': 'Sign in failed',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Sign up with email and password
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

      if (response.user != null) {
        return {
          'success': true,
          'user': response.user,
          'email': email,
          'message': 'Check your email to confirm your account',
        };
      }
      return {
        'success': false,
        'error': 'Sign up failed',
      };
    } on AuthException catch (e) {
      return {
        'success': false,
        'error': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An error occurred: ${e.toString()}',
      };
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// Get current user
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return supabase.auth.currentUser != null;
  }

  /// Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      return {
        'success': true,
        'message': 'Password reset email sent',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Update user profile in auth metadata
  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? phone,
  }) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': fullName,
            if (phone != null) 'phone': phone,
          },
        ),
      );
      return {
        'success': true,
        'message': 'Profile updated',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Store user data in database
  Future<Map<String, dynamic>> storeUserData({
    required String userId,
    required String email,
    required String fullName,
    required String userRole,
    String? phone,
  }) async {
    try {
      await supabase.from('users').insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'user_role': userRole,
        'phone': phone,
        'created_at': DateTime.now().toIso8601String(),
      });
      return {
        'success': true,
        'message': 'User data stored',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
