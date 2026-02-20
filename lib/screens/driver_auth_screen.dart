import 'package:flutter/material.dart';
import 'supabase_service.dart';

class DriverAuthScreen extends StatefulWidget {
  const DriverAuthScreen({super.key});

  @override
  State<DriverAuthScreen> createState() => _DriverAuthScreenState();
}

class _DriverAuthScreenState extends State<DriverAuthScreen> {
  int _selectedTab = 0; // 0: Sign In, 1: Sign Up, 2: Forgot Password

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();

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
                  const Icon(Icons.directions_car, color: Colors.white, size: 40),
                  const SizedBox(height: 10),
                  const Text(
                    'CarJa For Drivers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Earn money by displaying ads',
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
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildSignIn();
      case 1:
        return _buildSignUp();
      case 2:
        return _buildForgotPassword();
      default:
        return const SizedBox();
    }
  }

  Widget _buildSignIn() {
    return Column(
      children: [
        _buildFormGroup('Email Address', emailController, Icons.email),
        const SizedBox(height: 15),
        _buildFormGroup('Password', passwordController, Icons.lock, isPassword: true),
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
              '/dashboard',
              arguments: {
                'email': emailController.text,
                'userRole': 'driver', // FIX: Use lowercase
              },
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${result['error']}')),
            );
          }
        }),
        const SizedBox(height: 8),
        _buildSecondaryButton('CREATE ACCOUNT', () {
          setState(() => _selectedTab = 1);
        }),
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = 2),
            child: const Text(
              'DRIVER LOGIN',
              style: TextStyle(
                color: Color(0xFF003d99),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUp() {
    return Column(
      children: [
        _buildFormGroup('Full Name', fullNameController, Icons.person),
        const SizedBox(height: 15),
        _buildFormGroup('Email Address', emailController, Icons.email),
        const SizedBox(height: 15),
        _buildFormGroup('Phone Number', phoneController, Icons.phone),
        const SizedBox(height: 15),
        _buildFormGroup('Password', passwordController, Icons.lock, isPassword: true),
        const SizedBox(height: 20),
        _buildPrimaryButton('CONTINUE AS DRIVER', () async {
          if (fullNameController.text.isEmpty ||
              emailController.text.isEmpty ||
              phoneController.text.isEmpty ||
              passwordController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill in all fields')),
            );
            return;
          }

          final result = await SupabaseService().signUp(
            email: emailController.text,
            password: passwordController.text,
            fullName: fullNameController.text,
            userRole: 'driver',
          );

          if (result['success']) {
            Navigator.pushNamed(
              context,
              '/verification',
              arguments: {
                'email': result['email'],
                'userRole': 'driver', // FIX: Use lowercase
              },
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${result['error']}')),
            );
          }
        }),
        const SizedBox(height: 8),
        _buildSecondaryButton('BACK TO LOGIN', () {
          setState(() => _selectedTab = 0);
        }),
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = 0),
            child: const Text(
              'DRIVER SIGNUP',
              style: TextStyle(
                color: Color(0xFF003d99),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Column(
      children: [
        _buildFormGroup('Email Address', emailController, Icons.email),
        const SizedBox(height: 20),
        _buildPrimaryButton('SEND RESET LINK', () {
          if (emailController.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter your email')),
            );
            return;
          }

          // Show confirmation message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Check your email for password reset link'),
            ),
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

  Widget _buildFormGroup(String label, TextEditingController controller, IconData icon, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: label,
            prefixIcon: Icon(icon, color: const Color(0xFF666666)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFddd)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFddd)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF003d99)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF001a4d), Color(0xFF003d99)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
