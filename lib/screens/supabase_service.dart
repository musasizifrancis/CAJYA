import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  final supabase = Supabase.instance.client;

  // Sign in with email and password
  Future<String?> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user?.id;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  // Sign up with email and password
  Future<String?> signUp(String email, String password, String userRole) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'user_role': userRole},
      );
      return response.user?.id;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
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
  Future<void> updateUserMetadata(Map<String, dynamic> metadata) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(
          data: metadata,
        ),
      );
    } catch (e) {
      print('Update user error: $e');
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      await supabase.rpc('delete_user');
    } catch (e) {
      print('Delete account error: $e');
      rethrow;
    }
  }
}
