import 'package:flutter/material.dart';

class WithdrawalScreen extends StatefulWidget {
  final String email;
  final String userRole;

  const WithdrawalScreen({super.key, 
    required this.email,
    required this.userRole,
  });

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final TextEditingController _withdrawalAmountController =
      TextEditingController();
  double _withdrawalAmount = 0;
  double _serviceFee = 0;
  double _finalAmount = 0;

  @override
  void initState() {
    super.initState();
    _withdrawalAmountController.addListener(_calculateFees);
  }

  void _calculateFees() {
    setState(() {
      _withdrawalAmount =
          double.tryParse(_withdrawalAmountController.text) ?? 0;
      _serviceFee = _withdrawalAmount * 0.02; // 2% service fee
      _finalAmount = _withdrawalAmount - _serviceFee;
    });
  }

  @override
  void dispose() {
    _withdrawalAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF001a4d),
        elevation: 0,
        title: const Text(
          'Request Withdrawal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available Balance Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2ecc71), Color(0xFF27ae60)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'UGX 450,000',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Withdrawal Amount Label
            const Text(
              'WITHDRAWAL AMOUNT',
              style: TextStyle(
                color: Color(0xFF001a4d),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),

            // Withdrawal Amount Input
            TextField(
              controller: _withdrawalAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter amount (Min: UGX 50,000)',
                hintStyle: const TextStyle(color: Color(0x000ff999)),
                prefixText: 'UGX ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0x000ffddd)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0x000ffddd)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF003d99),
                    width: 2,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
              style: const TextStyle(
                color: Color(0x000ff333),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),

            // Payment Method Label
            const Text(
              'PAYMENT METHOD',
              style: TextStyle(
                color: Color(0xFF001a4d),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),

            // Payment Method Card
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFe0e0e0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFffcc00),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'M',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MTN Mobile Money',
                            style: TextStyle(
                              color: Color(0x000ff333),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '+256 700 123 456',
                            style: TextStyle(
                              color: Color(0x000ff666),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(Icons.check_circle,
                      color: Color(0xFF2ecc71), size: 24),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Fee Breakdown Label
            const Text(
              'FEE BREAKDOWN',
              style: TextStyle(
                color: Color(0xFF001a4d),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 15),

            // Fee Row 1: Gross Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gross Amount',
                  style: TextStyle(
                    color: Color(0x000ff666),
                    fontSize: 13,
                  ),
                ),
                Text(
                  'UGX ${_withdrawalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0x000ff333),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Fee Row 2: Service Fee
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Service Fee (2%)',
                  style: TextStyle(
                    color: Color(0x000ff666),
                    fontSize: 13,
                  ),
                ),
                Text(
                  '- UGX ${_serviceFee.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFFe74c3c),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Divider
            Container(
              height: 1,
              color: const Color(0xFFe0e0e0),
            ),
            const SizedBox(height: 15),

            // Fee Row 3: You'll Receive
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "You'll Receive",
                  style: TextStyle(
                    color: Color(0xFF001a4d),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'UGX ${_finalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Color(0xFF2ecc71),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF001a4d), Color(0xFF003d99)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF003d99).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (_withdrawalAmount >= 50000) {
                        // Process withdrawal
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Withdrawal request submitted!'),
                            backgroundColor: Color(0xFF2ecc71),
                          ),
                        );
                        Future.delayed(const Duration(seconds: 2), () {
                          Navigator.pop(context);
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Minimum withdrawal amount is UGX 50,000'),
                            backgroundColor: Color(0xFFe74c3c),
                          ),
                        );
                      }
                    },
                    child: const Center(
                      child: Text(
                        'CONFIRM WITHDRAWAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}