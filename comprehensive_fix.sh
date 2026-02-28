#!/bin/bash

echo "🔧 COMPREHENSIVE FIX FOR BUILD #192"

# FIX 1: Update main.dart routes to pass userId/driverId from ModalRoute arguments
echo "FIX 1: Updating main.dart routes..."
cat > lib/main_fix.dart << 'MAINEOF'
// In onGenerateRoute, replace the EditProfileScreen and DocumentsManagementScreen routes:

case '/edit-profile':
  final userId = settings.arguments as String?;
  return MaterialPageRoute(
    builder: (_) => EditProfileScreen(userId: userId ?? ''),
    settings: settings,
  );

case '/documents-management':
  final driverId = settings.arguments as String?;
  return MaterialPageRoute(
    builder: (_) => DocumentsManagementScreen(driverId: driverId ?? ''),
    settings: settings,
  );

case '/document-detail':
  final documentId = settings.arguments as String?;
  return MaterialPageRoute(
    builder: (_) => DocumentDetailScreen(documentId: documentId ?? ''),
    settings: settings,
  );
MAINEOF

# FIX 2: Rewrite api_service.dart methods to use supabase client instead of _client
echo "FIX 2: Fixing api_service.dart..."
cat > lib/services/api_service_methods_fix.dart << 'APIEOF'
// Replace these methods in api_service.dart:

static Future<bool> updatePersonalInfo({
  required String userId,
  required String fullName,
  required String dateOfBirth,
  required String phoneNumber,
  required String emergencyContact,
}) async {
  try {
    final supabase = Supabase.instance.client;
    await supabase
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
    throw Exception('Failed to update personal info: $e');
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
    final supabase = Supabase.instance.client;
    await supabase
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
    throw Exception('Failed to update vehicle info: $e');
  }
}

static Future<Map<String, dynamic>> getDocumentDetails(String documentId) async {
  try {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('driver_documents')
        .select()
        .eq('id', documentId)
        .single();
    return response as Map<String, dynamic>;
  } catch (e) {
    throw Exception('Failed to fetch document details: $e');
  }
}

static Future<bool> deleteDocument(String documentId) async {
  try {
    final supabase = Supabase.instance.client;
    await supabase
        .from('driver_documents')
        .delete()
        .eq('id', documentId);
    return true;
  } catch (e) {
    throw Exception('Failed to delete document: $e');
  }
}

static Future<List<Map<String, dynamic>>> getDriverNotifications(String driverId) async {
  try {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('driver_notifications')
        .select()
        .eq('driver_id', driverId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  } catch (e) {
    throw Exception('Failed to fetch notifications: $e');
  }
}

static Future<bool> markNotificationAsRead(String notificationId) async {
  try {
    final supabase = Supabase.instance.client;
    await supabase
        .from('driver_notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
    return true;
  } catch (e) {
    throw Exception('Failed to mark notification as read: $e');
  }
}

static Future<bool> deleteNotification(String notificationId) async {
  try {
    final supabase = Supabase.instance.client;
    await supabase
        .from('driver_notifications')
        .delete()
        .eq('id', notificationId);
    return true;
  } catch (e) {
    throw Exception('Failed to delete notification: $e');
  }
}

static Future<int> getUnreadNotificationCount(String driverId) async {
  try {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('driver_notifications')
        .select('id')
        .eq('driver_id', driverId)
        .eq('is_read', false);
    return (response as List).length;
  } catch (e) {
    throw Exception('Failed to fetch unread count: $e');
  }
}

static Future<Map<String, dynamic>> getProfileCompleteness(String userId) async {
  try {
    final supabase = Supabase.instance.client;
    final profile = await supabase
        .from('driver_profiles')
        .select()
        .eq('user_id', userId)
        .single();
    
    final data = profile as Map<String, dynamic>;
    int completeness = 0;
    
    if ((data['full_name'] as String?).isNotEmpty) completeness += 15;
    if ((data['date_of_birth'] as String?).isNotEmpty) completeness += 10;
    if ((data['phone_number'] as String?).isNotEmpty) completeness += 10;
    if ((data['vehicle_make'] as String?).isNotEmpty) completeness += 15;
    if ((data['vehicle_model'] as String?).isNotEmpty) completeness += 10;
    if ((data['vehicle_license_plate'] as String?).isNotEmpty) completeness += 10;
    if ((data['driver_documents'] as List?).isNotEmpty) completeness += 20;
    
    return {'completeness': completeness, 'profile': data};
  } catch (e) {
    throw Exception('Failed to calculate profile completeness: $e');
  }
}
APIEOF

# FIX 3: Rewrite EditProfileScreen to call API methods with named parameters
echo "FIX 3: Fixing EditProfileScreen..."
cat > lib/screens/edit_profile_screen_fix.dart << 'EDITEOF'
// Replace _updatePersonalInfo and _updateVehicleInfo methods:

Future<void> _updatePersonalInfo() async {
  try {
    await ApiService.updatePersonalInfo(
      userId: widget.userId,
      fullName: _nameController.text,
      dateOfBirth: _dobController.text,
      phoneNumber: _phoneController.text,
      emergencyContact: _emergencyContactController.text,
    );
    setState(() => _currentStep = 1);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Personal info updated')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

Future<void> _updateVehicleInfo() async {
  try {
    await ApiService.updateVehicleInfo(
      userId: widget.userId,
      vehicleMake: _makeController.text,
      vehicleModel: _modelController.text,
      vehicleYear: int.tryParse(_yearController.text) ?? 0,
      vehicleLicensePlate: _licensePlateController.text,
      vehicleColor: _colorController.text,
      vehicleTransmission: _transmissionController.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vehicle info updated')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
EDITEOF

echo "✅ FIX FILES CREATED"
echo "Now you need to manually apply these fixes to:"
echo "  1. lib/main.dart - Replace routes"
echo "  2. lib/services/api_service.dart - Replace the 9 methods"
echo "  3. lib/screens/edit_profile_screen.dart - Replace the 2 methods"

