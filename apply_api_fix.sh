#!/bin/bash

# Get the line numbers for our methods
echo "Finding method locations..."
UPDATEPERSONAL=$(grep -n "static Future<bool> updatePersonalInfo" lib/services/api_service.dart | cut -d: -f1)
UPDATEVEHICLE=$(grep -n "static Future<bool> updateVehicleInfo" lib/services/api_service.dart | cut -d: -f1)
GETDOCDETAILS=$(grep -n "static Future<Map<String, dynamic>> getDocumentDetails" lib/services/api_service.dart | cut -d: -f1)
DELETEDOC=$(grep -n "static Future<bool> deleteDocument" lib/services/api_service.dart | cut -d: -f1)
GETNOTIFS=$(grep -n "static Future<List<Map<String, dynamic>>> getDriverNotifications" lib/services/api_service.dart | cut -d: -f1)
MARKNOT=$(grep -n "static Future<bool> markNotificationAsRead" lib/services/api_service.dart | cut -d: -f1)
DELETENOT=$(grep -n "static Future<bool> deleteNotification" lib/services/api_service.dart | cut -d: -f1)
GETUNREAD=$(grep -n "static Future<int> getUnreadNotificationCount" lib/services/api_service.dart | cut -d: -f1)
GETCOMP=$(grep -n "static Future<Map<String, dynamic>> getProfileCompleteness" lib/services/api_service.dart | cut -d: -f1)

echo "Found methods at lines:"
echo "  updatePersonalInfo: $UPDATEPERSONAL"
echo "  updateVehicleInfo: $UPDATEVEHICLE"
echo "  getDocumentDetails: $GETDOCDETAILS"
echo "  deleteDocument: $DELETEDOC"
echo "  getDriverNotifications: $GETNOTIFS"
echo "  markNotificationAsRead: $MARKNOT"
echo "  deleteNotification: $DELETENOT"
echo "  getUnreadNotificationCount: $GETUNREAD"
echo "  getProfileCompleteness: $GETCOMP"

# We'll use Python for a more reliable replacement
python3 << 'PYEOF'
import re

with open('lib/services/api_service.dart', 'r') as f:
    content = f.read()

# FIX: Replace _client with supabase
content = content.replace('await _client', 'await Supabase.instance.client')
content = content.replace('final response = await _client', 'final response = await Supabase.instance.client')

with open('lib/services/api_service.dart', 'w') as f:
    f.write(content)

print("✅ Fixed all _client references to use Supabase.instance.client")
PYEOF

