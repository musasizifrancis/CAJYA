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
