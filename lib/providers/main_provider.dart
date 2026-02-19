import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _currentUserId;
  String? _currentUserRole;
  Map<String, dynamic>? _currentUserData;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserId => _currentUserId;
  String? get currentUserRole => _currentUserRole;
  Map<String, dynamic>? get currentUserData => _currentUserData;
  String? get errorMessage => _errorMessage;

  Future<void> initializeAuth() async {
    try {
      _isLoading = true;
      notifyListeners();

      final session = _supabase.auth.currentSession;
      if (session != null) {
        _currentUserId = session.user.id;
        _isLoggedIn = true;
        await fetchUserData();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Init failed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUserId = response.user!.id;
        _isLoggedIn = true;
        await fetchUserData();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerWithEmail(String email, String password, String role) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUserId = response.user!.id;
        _currentUserRole = role;

        await _supabase.from('users').insert({
          'id': response.user!.id,
          'email': email,
          'role': role,
          'created_at': DateTime.now().toIso8601String(),
        });

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchUserData() async {
    try {
      if (_currentUserId == null) return;

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', _currentUserId!)
          .single();

      _currentUserData = response;
      _currentUserRole = response['role'];
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Fetch failed: $e';
      notifyListeners();
    }
  }

  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.from('users').update(updates).eq('id', _currentUserId!);

      _currentUserData = {...?_currentUserData, ...updates};
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Update failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.signOut();
      _currentUserId = null;
      _isLoggedIn = false;
      _currentUserRole = null;
      _currentUserData = null;
      _errorMessage = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
