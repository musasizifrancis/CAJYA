import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../utils/animations.dart';

class WithdrawalRequestScreen extends StatefulWidget {
  final double currentBalance;
  final String driverId;

  const WithdrawalRequestScreen({
    Key? key,
    required this.currentBalance,
    required this.driverId,
  }) : super(key: key);

  @override
  State<WithdrawalRequestScreen> createState() =>
      _WithdrawalRequestScreenState();
}

class _WithdrawalRequestScreenState extends State<WithdrawalRequestScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // UGX Settings
  static const double MINIMUM_WITHDRAWAL = 5000; // UGX 5,000
  static const String CURRENCY = 'UGX';

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    setState(() {
      _errorMessage = null;
    });

    final amountText = _amountController.text.trim();
    final phone = _phoneController.text.trim();

    if (amountText.isEmpty) {
      setState(() => _errorMessage = 'Please enter an amount');
      return false;
    }

    final amount = double.tryParse(amountText);
    if (amount == null) {
      setState(() => _errorMessage = 'Invalid amount format');
      return false;
    }

    if (amount < MINIMUM_WITHDRAWAL) {
      setState(
        () => _errorMessage =
            'Minimum withdrawal is $CURRENCY ${MINIMUM_WITHDRAWAL.toStringAsFixed(0)}',
      );
      return false;
    }

    if (amount > widget.currentBalance) {
      setState(
        () => _errorMessage = 'Cannot withdraw more than your balance',
      );
      return false;
    }

    if (phone.isEmpty) {
      setState(() => _errorMessage = 'Please enter MTN phone number');
      return false;
    }

    // Validate Uganda phone number (256XXXXXXXXX, +256XXXXXXXXX, or 07XXXXXXXXX)
    final phoneRegex = RegExp(r'^(\+?256|0)[7-9]\d{8}$');
    if (!phoneRegex.hasMatch(phone.replaceAll(' ', ''))) {
      setState(
        () => _errorMessage =
            'Invalid phone number. Use format: 256XXXXXXXXX, +256XXXXXXXXX, or 07XXXXXXXXX',
      );
      return false;
    }

    return true;
  }

  Future<void> _submitWithdrawal() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text.trim());
      final phone = _phoneController.text.trim();

      // Create withdrawal request
      final success = await PaymentService.requestWithdrawal(
        driverId: widget.driverId,
        amount: amount,
        currency: CURRENCY,
        phoneNumber: phone,
      );

      if (success) {
        setState(() {
          _successMessage = 'Withdrawal request submitted successfully!';
          _amountController.clear();
          _phoneController.clear();
        });

        // Show success dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1A2A5E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                '✅ Withdrawal Request Submitted',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Your withdrawal of $CURRENCY ${amount.toStringAsFixed(0)} has been requested.\n\nIt may take 1-2 hours to process.',
                style: const TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context); // Go back to Earnings tab
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(color: Color(0xFF6366F1)),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        setState(
          () => _errorMessage =
              'Failed to process withdrawal. Please try again.',
        );
      }
    } catch (e) {
      setState(
        () => _errorMessage = 'Error: ${e.toString()}',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1729),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2A5E),
        elevation: 0,
        title: const Text(
          'Request Withdrawal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeInWidget(
        duration: const Duration(milliseconds: 500),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Current Balance Card
            SlideInWidget(
              direction: SlideDirection.up,
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 100),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A2A5E), Color(0xFF2D3E7F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$CURRENCY ${widget.currentBalance.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Form Section
            SlideInWidget(
              direction: SlideDirection.up,
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount Field
                  const Text(
                    'Withdrawal Amount',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter amount in $CURRENCY',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixText: '$CURRENCY ',
                      prefixStyle: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1A2A5E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6366F1),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6366F1),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6366F1),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Phone Field
                  const Text(
                    'MTN Phone Number',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '256XXXXXXXXX or 07XXXXXXXXX',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.phone,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1A2A5E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6366F1),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6366F1),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6366F1),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Error Message
            if (_errorMessage != null)
              ScaleInWidget(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Success Message
            if (_successMessage != null)
              ScaleInWidget(
                duration: const Duration(milliseconds: 400),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Submit Button
            SlideInWidget(
              direction: SlideDirection.up,
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 400),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitWithdrawal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  disabledBackgroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Submit Withdrawal Request',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2A5E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6366F1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ℹ️ Important Information',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Minimum withdrawal: $CURRENCY 5,000\n'
                    '• Processing time: 1-2 hours\n'
                    '• Funds sent directly to your MTN account\n'
                    '• Check your withdrawal history below',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
