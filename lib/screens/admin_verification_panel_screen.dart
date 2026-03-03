import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/admin_service.dart';

class AdminVerificationPanelScreen extends StatefulWidget {
  const AdminVerificationPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminVerificationPanelScreen> createState() =>
      _AdminVerificationPanelScreenState();
}

class _AdminVerificationPanelScreenState
    extends State<AdminVerificationPanelScreen> {
  int _selectedTabIndex = 0;
  Map<String, int> _stats = {'pending': 0, 'approved': 0, 'rejected': 0};
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await AdminService.getVerificationStats();
      
      List<Map<String, dynamic>> docs = [];
      if (_selectedTabIndex == 0) {
        docs = await AdminService.getPendingDocuments();
      } else if (_selectedTabIndex == 1) {
        docs = await AdminService.getApprovedDocuments();
      } else {
        docs = await AdminService.getRejectedDocuments();
      }

      setState(() {
        _stats = stats;
        _documents = docs;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  void _refreshData() {
    _loadData();
  }

  void _onTabChanged(int index) {
    setState(() => _selectedTabIndex = index);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Verification'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1E3A8A),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error ?? 'An error occurred'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _refreshData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Statistics Cards
                    _buildStatsSection(),
                    // Tab Navigation
                    Material(
                      color: Colors.grey[100],
                      child: TabBar(
                        onTap: _onTabChanged,
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.pending_actions),
                                const SizedBox(width: 8),
                                Text('Pending (${_stats['pending'] ?? 0})'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle),
                                const SizedBox(width: 8),
                                Text('Approved (${_stats['approved'] ?? 0})'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.cancel),
                                const SizedBox(width: 8),
                                Text('Rejected (${_stats['rejected'] ?? 0})'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Documents List
                    Expanded(
                      child: _documents.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _selectedTabIndex == 0
                                        ? Icons.pending_actions
                                        : _selectedTabIndex == 1
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _selectedTabIndex == 0
                                        ? 'No pending documents'
                                        : _selectedTabIndex == 1
                                            ? 'No approved documents'
                                            : 'No rejected documents',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _documents.length,
                              itemBuilder: (context, index) {
                                final doc = _documents[index];
                                return _buildDocumentCard(context, doc);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatCard(
            'Pending',
            _stats['pending'] ?? 0,
            Colors.orange,
            Icons.pending_actions,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Approved',
            _stats['approved'] ?? 0,
            Colors.green,
            Icons.check_circle,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            'Rejected',
            _stats['rejected'] ?? 0,
            Colors.red,
            Icons.cancel,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    Map<String, dynamic> doc,
  ) {
    final status = doc['verification_status'] as String?;
    final driverProfile = doc['driver_profiles'] as Map<String, dynamic>?;
    final driverName = driverProfile?['full_name'] as String? ?? 'Unknown Driver';
    final docType = doc['document_type'] as String? ?? 'Document';
    final uploadedAt = doc['created_at'] as String?;

    Color statusColor;
    IconData statusIcon;

    if (status == 'approved') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == 'rejected') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.pending_actions;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(driverName),
        subtitle: Text('$docType • ${_formatDate(uploadedAt)}'),
        trailing: Icon(statusIcon, color: statusColor),
        onTap: () => _openDocumentReview(context, doc),
      ),
    );
  }

  void _openDocumentReview(
    BuildContext context,
    Map<String, dynamic> doc,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentReviewScreen(document: doc),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

class DocumentReviewScreen extends StatefulWidget {
  final Map<String, dynamic> document;

  const DocumentReviewScreen({
    Key? key,
    required this.document,
  }) : super(key: key);

  @override
  State<DocumentReviewScreen> createState() => _DocumentReviewScreenState();
}

class _DocumentReviewScreenState extends State<DocumentReviewScreen> {
  late String _selectedReason;
  final TextEditingController _customReasonController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _rejectionReasons = [
    'Image too blurry',
    'Document expired',
    'Information mismatch',
    'Document not fully visible',
    'Wrong document type',
    'Custom reason',
  ];

  @override
  void initState() {
    super.initState();
    _selectedReason = _rejectionReasons.first;
  }

  Future<void> _approveDocument() async {
    setState(() => _isSubmitting = true);
    try {
      final docId = widget.document['id'] as String;
      await AdminService.approveDocument(
        documentId: docId,
        verifiedBy: 'admin',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document approved')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _rejectDocument() async {
    final reason = _selectedReason == 'Custom reason'
        ? _customReasonController.text
        : _selectedReason;

    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rejection reason')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final docId = widget.document['id'] as String;
      await AdminService.rejectDocument(
        documentId: docId,
        verifiedBy: 'admin',
        rejectionReason: reason,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document rejected')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.document['verification_status'] as String?;
    final driverProfile = widget.document['driver_profiles'] as Map<String, dynamic>?;
    final driverName = driverProfile?['full_name'] as String? ?? 'Unknown';
    final docType = widget.document['document_type'] as String? ?? 'Document';
    final documentUrl = widget.document['document_url'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Document'),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Driver: $driverName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Document: $docType'),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(status ?? 'Unknown'),
                      backgroundColor: _getStatusColor(status),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Document Preview
            if (documentUrl != null) ...[
              const Text(
                'Document Preview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.network(
                  documentUrl,
                  fit: BoxFit.cover,
                  height: 300,
                  errorBuilder: (_, __, ___) => Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Text('Document preview unavailable'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            if (status == 'pending') ...[
              const Text(
                'Verification Action',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _approveDocument,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Approve Document'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _showRejectDialog,
                  icon: const Icon(Icons.cancel),
                  label: const Text('Reject Document'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ] else
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'This document has already been ${status?.toUpperCase()}.',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject Document'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select a reason:'),
              const SizedBox(height: 12),
              ..._rejectionReasons.map((reason) {
                return RadioListTile<String>(
                  title: Text(reason),
                  value: reason,
                  groupValue: _selectedReason,
                  onChanged: (value) {
                    setState(() => _selectedReason = value!);
                    Navigator.pop(context);
                    _showRejectDialog();
                  },
                );
              }),
              if (_selectedReason == 'Custom reason') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _customReasonController,
                  decoration: const InputDecoration(
                    hintText: 'Enter custom reason',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _rejectDocument,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
