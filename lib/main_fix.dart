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
