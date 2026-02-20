import 'package:flutter/material.dart';
import 'supabase_service.dart';

class BrandAuthScreen extends StatefulWidget {
  const BrandAuthScreen({super.key});

  @override
  State<BrandAuthScreen> createState() => _BrandAuthScreenState();
}

class _BrandAuthScreenState extends State<BrandAuthScreen> {
  int _selectedTab = 0; // 0: Sign In, 1: Sign Up, 2: Forgot Password

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final companyNameController = TextEditingController();
  final contactPersonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF001a4d), Color(0xFF003d99)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Icon(Icons.business, color: Colors.white, size: 40),
                  const SizedBox(height: 10),
                  const Text(
                    'CarJa For Brands',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Manage your ad campaigns',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tab Selector
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFe0e0e0)),
              ),
              child: Row(
                children: [
                  _buildTab('SIGN IN', 0),
                  _buildTab('SIGN UP', 1),
                  _buildTab('FORGOT', 2),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildTabContent(),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF001a4d), Color(0xFF003d99)],
                  )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF666666),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return switch (_selectedTab) {
      0 => _buildSignIn(),
      1 => _buildSignUp(),
      2 => _buildForgotPassword(),
      _ => const SizedBox(),
    };
  }

  Widget _buildSignIn() {
    return Column(
      children: [
        _buildInputField('Email', emailController, false),
        const SizedBox(height: 16),
        _buildInputField('Password', passwordController, true),
        const SizedBox(height: 20),
        _buildPrimaryButton('SIGN IN', () async {
          if (emailController.text.isEmpty || passwordController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill in all fields')),
            );
            return;
          }

          final result = await SupabaseService().signIn(
            email: emailController.text,
            password: passwordController.text,
          );

          if (result['success']) {
            Navigator.pushNamed(
              context,
              '/brand-dashboard',
              arguments: {
                'email': emailController.text,
                'userRole': 'brand', // FIX: Use lowercase
              },
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${result['error']}')),
            );
          }
        }),
        const SizedBox(height: 12),
        _buildSecondaryButton('CREATE ACCOUNT', () {
          setState(() => _selectedTab = 1);
        }),
      ],
    );
  }

  Widget _buildSignUp() {
    return Column(
      children: [
        _buildInputField('Company Name', companyNameController, false),
        const SizedBox(height: 16),
        _buildInputField('Contact Person', contactPersonController, false),
        const SizedBox(height: 16),
        _buildInputField('Email', emailController, false),
        const SizedBox(height: 16),
        _buildInputField('Password', passwordController, true),
        const SizedBox(height: 20),
        _buildPrimaryButton('CREATE ACCOUNT', () async {
          if (companyNameController.text.isEmpty ||
              contactPersonController.text.isEmpty ||
              emailController.text.isEmpty ||
              passwordController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill in all fields')),
            );
            return;
          }

          final result = await SupabaseService().signUp(
            email: emailController.text,
            password: passwordController.text,
            fullName: companyNameController.text,
            userRole: 'brand',
          );

          if (result['success']) {
            Navigator.pushNamed(
              context,
              '/verification',
              arguments: {
                'email': emailController.text,
                'userRole': 'brand', // FIX: Use lowercase
              },
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${result['error']}')),
            );
          }
        }),
        const SizedBox(height: 12),
        _buildSecondaryButton('BACK TO LOGIN', () {
          setState(() => _selectedTab = 0);
        }),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Column(
      children: [
        _buildInputField('Email', emailController, false),
        const SizedBox(height: 20),
        _buildPrimaryButton('SEND RESET LINK', () {
          if (emailController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter your email')),
            );
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Check your email for password reset link')),
          );
          emailController.clear();
        }),
        const SizedBox(height: 8),
        _buildSecondaryButton('BACK TO LOGIN', () {
          setState(() => _selectedTab = 0);
        }),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF003d99),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    companyNameController.dispose();
    contactPersonController.dispose();
    super.dispose();
  }
}
