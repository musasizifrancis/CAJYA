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
      appBar: AppBar(
        title: const Text('Document Details'),
        elevation: 0,
      ),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Document Type
                _buildInfoCard(
                  'Document Type',
                  doc['document_type'] ?? 'N/A',
                ),
                const SizedBox(height: 16),

                // Status
                _buildInfoCard(
                  'Verification Status',
                  doc['verification_status'] ?? 'pending',
                  statusValue: true,
                ),
                const SizedBox(height: 16),

                // Upload Date
                _buildInfoCard(
                  'Uploaded On',
                  doc['uploaded_at'] ?? 'N/A',
                ),
                const SizedBox(height: 16),

                // File URL
                if (doc['file_url'] != null)
                  _buildInfoCard(
                    'File URL',
                    doc['file_url'],
                  ),
                const SizedBox(height: 16),

                // Rejection Reason (if rejected)
                if (doc['verification_status'] == 'rejected' && doc['rejection_reason'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(
                        'Rejection Reason',
                        doc['rejection_reason'],
                        isError: true,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                // Verified By (if approved)
                if (doc['verified_by'] != null)
                  _buildInfoCard(
                    'Verified By',
                    doc['verified_by'],
                  ),
                const SizedBox(height: 16),

                // Verified At (if approved)
                if (doc['verified_at'] != null)
                  _buildInfoCard(
                    'Verified On',
                    doc['verified_at'],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value, {
    bool statusValue = false,
    bool isError = false,
  }) {
    Color? backgroundColor;
    Color? textColor;

    if (statusValue) {
      if (value == 'approved') {
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
      } else if (value == 'rejected') {
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
      } else {
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
      }
    } else if (isError) {
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
    }

    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
