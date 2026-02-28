import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DocumentDetailScreen extends StatefulWidget {
  final String documentId;

  const DocumentDetailScreen({
    Key? key,
    required this.documentId,
  }) : super(key: key);

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  late Future<Map<String, dynamic>> _documentFuture;

  @override
  void initState() {
    super.initState();
    _documentFuture = ApiService.getDocumentDetails(widget.documentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Details')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _documentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final doc = snapshot.data ?? {};
          final docType = doc['document_type'] as String? ?? 'Unknown';
          final status = doc['verification_status'] as String?;
          final uploadedAt = doc['uploaded_at'] as String?;
          final verifiedAt = doc['verified_at'] as String?;
          final verifiedBy = doc['verified_by'] as String?;
          final rejectionReason = doc['rejection_reason'] as String?;
          final fileUrl = doc['file_url'] as String?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  docType,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status?.toUpperCase() ?? 'UNKNOWN',
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildDetailTile('Document Type', docType),
                _buildDetailTile('Status', status ?? 'Unknown'),
                if (uploadedAt != null) _buildDetailTile('Uploaded', uploadedAt),
                if (verifiedAt != null) _buildDetailTile('Verified', verifiedAt),
                if (verifiedBy != null) _buildDetailTile('Verified By', verifiedBy),
                if (rejectionReason != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rejection Reason',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        Text(rejectionReason),
                      ],
                    ),
                  ),
                ],
                if (fileUrl != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _openFile(fileUrl),
                    icon: const Icon(Icons.download),
                    label: const Text('Download Document'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 12),
      ],
    );
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

  void _openFile(String fileUrl) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening: $fileUrl')),
    );
  }
}
