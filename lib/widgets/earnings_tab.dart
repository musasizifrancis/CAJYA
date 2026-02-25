import 'package:flutter/material.dart';
import 'package:cajya/services/api_service.dart';
import 'package:cajya/screens/withdrawal_request_screen.dart';

class EarningsTabWidget extends StatefulWidget {
  final String driverId;

  const EarningsTabWidget({
    Key? key,
    required this.driverId,
  }) : super(key: key);

  @override
  State<EarningsTabWidget> createState() => _EarningsTabWidgetState();
}

class _EarningsTabWidgetState extends State<EarningsTabWidget> {
  late Future<double> _totalEarnings;
  late Future<double> _withdrawableBalance;
  late Future<List<Map<String, dynamic>>> _withdrawalHistory;

  @override
  void initState() {
    super.initState();
    _loadEarningsData();
  }

  void _loadEarningsData() {
    _totalEarnings = ApiService.getTotalEarnings(widget.driverId);
    _withdrawableBalance = ApiService.getTotalEarnings(widget.driverId);
    _withdrawalHistory = ApiService.getWithdrawalHistory(widget.driverId);
  }

  void _refreshData() {
    setState(() {
      _loadEarningsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Earnings Card
              _buildEarningsCard(),
              const SizedBox(height: 20),

              // Withdrawable Balance Card
              _buildWithdrawableBalanceCard(),
              const SizedBox(height: 20),

              // Request Withdrawal Button
              _buildWithdrawalButton(),
              const SizedBox(height: 30),

              // Withdrawal History Header
              _buildSectionHeader('Withdrawal History'),
              const SizedBox(height: 12),

              // Withdrawal History List
              _buildWithdrawalHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsCard() {
    return FutureBuilder<double>(
      future: _totalEarnings,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard('Total Earnings', height: 120);
        }

        if (snapshot.hasError) {
          return _buildErrorCard('Failed to load earnings');
        }

        final earnings = snapshot.data ?? 0.0;

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.attach_money,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Total Earnings',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${earnings.toStringAsFixed(0)} UGX',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWithdrawableBalanceCard() {
    return FutureBuilder<double>(
      future: _withdrawableBalance,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard('Withdrawable Balance', height: 120);
        }

        if (snapshot.hasError) {
          return _buildErrorCard('Failed to load balance');
        }

        final balance = snapshot.data ?? 0.0;

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF059669), Color(0xFF10B981)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.wallet,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Available to Withdraw',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${balance.toStringAsFixed(0)} UGX',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWithdrawalButton() {
    return FutureBuilder<double>(
      future: _withdrawableBalance,
      builder: (context, snapshot) {
        final balance = snapshot.data ?? 0.0;
        final isEnabled = balance >= 5000 && snapshot.connectionState == ConnectionState.done;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isEnabled
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WithdrawalRequestScreen(
                          driverId: widget.driverId,
                          currentBalance: balance,
                          onSuccess: _refreshData,
                        ),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              disabledBackgroundColor: Colors.grey[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              balance < 5000 ? 'Minimum 5,000 UGX required' : 'Request Withdrawal',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildWithdrawalHistory() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _withdrawalHistory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: [
              _buildLoadingCard('', height: 100),
              const SizedBox(height: 12),
              _buildLoadingCard('', height: 100),
            ],
          );
        }

        if (snapshot.hasError) {
          return _buildErrorCard('Failed to load withdrawal history');
        }

        final withdrawals = snapshot.data ?? [];

        if (withdrawals.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'No withdrawals yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: withdrawals.length,
          itemBuilder: (context, index) {
            final withdrawal = withdrawals[index];
            return _buildWithdrawalCard(withdrawal);
          },
        );
      },
    );
  }

  Widget _buildWithdrawalCard(Map<String, dynamic> withdrawal) {
    final status = withdrawal['status'] as String? ?? 'pending';
    final amount = withdrawal['amount'] as double? ?? 0.0;
    final mtnNumber = withdrawal['mtn_number'] as String? ?? 'N/A';
    final createdAt = withdrawal['created_at'] as String? ?? '';

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'completed':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle;
        break;
      case 'failed':
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.schedule;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${amount.toStringAsFixed(0)} UGX',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mtnNumber,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(String label, {required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: label.isEmpty
          ? const SizedBox.expand()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 24,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAEA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEF4444),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFEF4444),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}
