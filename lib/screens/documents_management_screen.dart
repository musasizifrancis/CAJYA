import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/document_detail_screen.dart';

class DocumentsManagementScreen extends StatefulWidget {
  final String driverId;

  const DocumentsManagementScreen({
    Key? key,
    required this.driverId,
  }) : super(key: key);

  @override
  State<DocumentsManagementScreen> createState() => _DocumentsManagementScreenState();
}

class _DocumentsManagementScreenState extends State<DocumentsManagementScreen> {
  late Future<List<Map<String, dynamic>>> _documentsFuture;

  @override
  void initState() {
    super.initState();
    _documentsFuture = _loadDocuments();
  }

  Future<List<Map<String, dynamic>>> _loadDocuments() async {
    return await ApiService.getDriverDocuments(widget.driverId);
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _getStatusLabel(String? status) {
    return status?.toUpperCase() ?? 'UNKNOWN';
  }

  Future<void> _deleteDocument(String documentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to delete this document?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deleteDocument(documentId);
        setState(() {
          _documentsFuture = _loadDocuments();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Documents')),
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
            return const Center(child: Text('No documents uploaded'));
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              final docId = doc['id'] as String?;
              final docType = doc['document_type'] as String? ?? 'Unknown';
              final status = doc['verification_status'] as String?;
              final rejectionReason = doc['rejection_reason'] as String?;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(docType),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusLabel(status),
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (rejectionReason != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Rejection: $rejectionReason',
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'view' && docId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DocumentDetailScreen(documentId: docId),

                          ),
                        );
                      } else if (value == 'delete' && docId != null) {
                        _deleteDocument(docId);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(value: 'view', child: Text('View')),
                      if (status == 'rejected')
                        const PopupMenuItem(value: 'reupload', child: Text('Re-upload')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
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
}
