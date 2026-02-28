import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart';

class DocumentsManagementScreen extends StatefulWidget {
  const DocumentsManagementScreen({Key? key}) : super(key: key);

  @override
  State<DocumentsManagementScreen> createState() => _DocumentsManagementScreenState();
}

class _DocumentsManagementScreenState extends State<DocumentsManagementScreen> {
  late String _driverId;
  late Future<List<Map<String, dynamic>>> _documentsFuture;

  @override
  void initState() {
    super.initState();
    _driverId = Supabase.instance.client.auth.currentUser?.id ?? '';
    _documentsFuture = ApiService.getDriverDocuments(_driverId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _documentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final documents = snapshot.data ?? [];

          if (documents.isEmpty) {
            return const Center(child: Text('No documents uploaded yet'));
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              final status = doc['verification_status'] ?? 'pending';
              
              Color statusColor;
              IconData statusIcon;

              switch (status) {
                case 'approved':
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle;
                  break;
                case 'rejected':
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel;
                  break;
                default:
                  statusColor = Colors.orange;
                  statusIcon = Icons.schedule;
              }

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Icon(statusIcon, color: statusColor),
                  title: Text(doc['document_type'] ?? 'Document'),
                  subtitle: Text('Status: $status'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('View'),
                        onTap: () => Navigator.of(context).pushNamed(
                          '/document-detail',
                          arguments: {'documentId': doc['id']},
                        ),
                      ),
                      if (status == 'rejected')
                        PopupMenuItem(
                          child: const Text('Re-upload'),
                          onTap: () {
                            // TODO: Show re-upload dialog
                          },
                        ),
                      PopupMenuItem(
                        child: const Text('Delete'),
                        onTap: () => _deleteDocument(doc['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteDocument(String documentId) async {
    try {
      await ApiService.deleteDocument(documentId);
      if (mounted) {
        setState(() {
          _documentsFuture = ApiService.getDriverDocuments(_driverId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting document: $e')),
        );
      }
    }
  }
}
