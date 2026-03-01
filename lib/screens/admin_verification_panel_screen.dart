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
  List<Map<String, dynamic>> _pendingDocuments = [];
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
      final docs = await AdminService.getPendingDocuments();

      setState(() {
        _stats = stats;
        _pendingDocuments = docs;
        _isLoading = false;
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
                        controller: null,
                        onTap: (index) {
                          setState(() => _selectedTabIndex = index);
                        },
                        tabs: [
                          Tab(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.pending_actions),
                                const SizedBox(height: 4),
                                Text('Pending (${_stats['pending'] ?? 0})'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle),
                                const SizedBox(height: 4),
                                Text('Approved (${_stats['approved'] ?? 0})'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.cancel),
                                const SizedBox(height: 4),
                                Text('Rejected (${_stats['rejected'] ?? 0})'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Documents List
                    Expanded(
                      child: _buildDocumentsList(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      color: const Color(0xFF1E3A8A),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard(
            'Pending',
            _stats['pending']?.toString() ?? '0',
            Colors.orange,
            Icons.pending_actions,
          ),
          _buildStatCard(
            'Approved',
            _stats['approved']?.toString() ?? '0',
            Colors.green,
            Icons.check_circle,
          ),
          _buildStatCard(
            'Rejected',
            _stats['rejected']?.toString() ?? '0',
            Colors.red,
            Icons.cancel,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String count,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                count,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentsList() {
    final docs = _selectedTabIndex == 0
        ? _pendingDocuments
        : _selectedTabIndex == 1
            ? _pendingDocuments.where((d) => d['verification_status'] == 'approved').toList()
            : _pendingDocuments
                .where((d) => d['verification_status'] == 'rejected')
                .toList();

    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedTabIndex == 0
                  ? Icons.check_circle
                  : Icons.inbox,
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
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        return _buildDocumentCard(context, doc);
      },
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    Map<String, dynamic> doc,
  ) {
    final docType = doc['document_type'] ?? 'Unknown';
    final driverName =
        doc['driver_profiles']?['full_name'] ?? 'Unknown Driver';
    final status = doc['verification_status'] ?? 'pending';
    final uploadedAt = doc['created_at'] != null
        ? DateFormat('MMM d, yyyy').format(DateTime.parse(doc['created_at']))
        : 'Unknown';

    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.pending_actions;

    if (status == 'approved') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status == 'rejected') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          driverName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(docType, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 4),
            Text(uploadedAt, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DocumentReviewScreen(
                document: doc,
                onDocumentVerified: _refreshData,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Document Review Screen
class DocumentReviewScreen extends StatefulWidget {
  final Map<String, dynamic> document;
  final VoidCallback onDocumentVerified;

  const DocumentReviewScreen({
    Key? key,
    required this.document,
    required this.onDocumentVerified,
  }) : super(key: key);

  @override
  State<DocumentReviewScreen> createState() => _DocumentReviewScreenState();
}

class _DocumentReviewScreenState extends State<DocumentReviewScreen> {
  late TextEditingController _rejectionReasonController;
  bool _isProcessing = false;
  String? _selectedRejectionReason;

  final List<String> _commonRejectionReasons = [
    'Document is blurry or unclear',
    'Document is expired',
    'Missing required information',
    'Document does not match profile',
    'Poor photo quality',
    'Other (specify below)',
  ];

  @override
  void initState() {
    super.initState();
    _rejectionReasonController = TextEditingController();
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  Future<void> _approveDocument() async {
    setState(() => _isProcessing = true);
    try {
      await AdminService.approveDocument(
        documentId: widget.document['id'],
        verifiedBy: 'admin_user',
      );

      // Send notification to driver
      await AdminService.sendNotificationToDriver(
        driverId: widget.document['driver_id'],
        title: 'Document Approved ✅',
        message:
            '${widget.document['document_type']} has been approved. Great job!',
        metadata: {'documentId': widget.document['id']},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document approved successfully')),
        );
        widget.onDocumentVerified();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _rejectDocument() async {
    if (_rejectionReasonController.text.isEmpty &&
        _selectedRejectionReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rejection reason')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final reason = _selectedRejectionReason == 'Other (specify below)'
          ? _rejectionReasonController.text
          : (_selectedRejectionReason ?? '');

      await AdminService.rejectDocument(
        documentId: widget.document['id'],
        rejectionReason: reason,
        rejectedBy: 'admin_user',
      );

      // Send notification to driver
      await AdminService.sendNotificationToDriver(
        driverId: widget.document['driver_id'],
        title: 'Document Rejected ❌',
        message:
            '${widget.document['document_type']} needs to be resubmitted. Reason: $reason',
        metadata: {
          'documentId': widget.document['id'],
          'rejectionReason': reason,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document rejected')),
        );
        widget.onDocumentVerified();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Document'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select or provide a rejection reason:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              ..._commonRejectionReasons.map((reason) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedRejectionReason = reason);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedRejectionReason == reason
                              ? const Color(0xFF1E3A8A)
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: reason,
                            groupValue: _selectedRejectionReason,
                            onChanged: (val) {
                              setState(() => _selectedRejectionReason = val);
                            },
                          ),
                          Expanded(child: Text(reason)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 12),
              if (_selectedRejectionReason == 'Other (specify below)')
                TextField(
                  controller: _rejectionReasonController,
                  decoration: InputDecoration(
                    hintText: 'Please specify the reason...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isProcessing ? null : () {
              Navigator.pop(context);
              _rejectDocument();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.document['verification_status'] ?? 'pending';
    final docType = widget.document['document_type'] ?? 'Unknown';
    final driverName =
        widget.document['driver_profiles']?['full_name'] ?? 'Unknown';
    final uploadedAt = widget.document['created_at'] != null
        ? DateFormat('MMM d, yyyy HH:mm')
            .format(DateTime.parse(widget.document['created_at']))
        : 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Document'),
        elevation: 0,
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Document Info Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    docType,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Driver: $driverName',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Uploaded: $uploadedAt',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: status == 'pending'
                                    ? Colors.orange[100]
                                    : status == 'approved'
                                        ? Colors.green[100]
                                        : Colors.red[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: status == 'pending'
                                      ? Colors.orange[800]
                                      : status == 'approved'
                                          ? Colors.green[800]
                                          : Colors.red[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Document Preview
                Card(
                  elevation: 2,
                  child: Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[200],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Document Preview\n(${widget.document['file_path'] ?? 'No file path'})',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Rejection Reason (if applicable)
                if (status == 'rejected' && widget.document['rejection_reason'] != null)
                  Card(
                    color: Colors.red[50],
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.cancel, color: Colors.red[700]),
                              const SizedBox(width: 8),
                              const Text(
                                'Rejection Reason',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(widget.document['rejection_reason']),
                        ],
                      ),
                    ),
                  ),

                // Metadata
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Document Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow('Document Type', docType),
                        _buildDetailRow('Driver Name', driverName),
                        _buildDetailRow(
                          'Document ID',
                          widget.document['id']?.substring(0, 8) ?? 'N/A',
                        ),
                        _buildDetailRow('Status', status.toUpperCase()),
                        if (widget.document['verified_at'] != null)
                          _buildDetailRow(
                            'Verified At',
                            DateFormat('MMM d, yyyy HH:mm').format(
                              DateTime.parse(widget.document['verified_at']),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),

          // Action Buttons
          if (status == 'pending')
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _isProcessing ? null : _showRejectDialog,
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _isProcessing ? null : _approveDocument,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
