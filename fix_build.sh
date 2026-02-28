#!/bin/bash

# FIX 1: Replace all _client references with http.get/post/put/delete in api_service.dart
sed -i 's/await _client\.get(/await http.get(/g' lib/services/api_service.dart
sed -i 's/await _client\.post(/await http.post(/g' lib/services/api_service.dart
sed -i 's/await _client\.put(/await http.put(/g' lib/services/api_service.dart
sed -i 's/await _client\.delete(/await http.delete(/g' lib/services/api_service.dart
sed -i 's/await _client\.patch(/await http.patch(/g' lib/services/api_service.dart

echo "✅ Fixed http client references"

# FIX 2: Fix EditProfileScreen null-safety and Stepper
cat > lib/screens/edit_profile_screen.dart << 'SCREENEOF'
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;

  const EditProfileScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  int _currentStep = 0;
  bool _loading = true;
  String? _error;

  // Personal info controllers
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  // Vehicle info controllers
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _colorController = TextEditingController();
  final _transmissionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ApiService.getDriverProfile(widget.userId);
      if (data != null) {
        setState(() {
          _nameController.text = data['full_name'] as String? ?? '';
          _dobController.text = data['date_of_birth'] as String? ?? '';
          _phoneController.text = data['phone_number'] as String? ?? '';
          _emergencyContactController.text = data['emergency_contact'] as String? ?? '';
          _makeController.text = data['vehicle_make'] as String? ?? '';
          _modelController.text = data['vehicle_model'] as String? ?? '';
          _yearController.text = (data['vehicle_year'] as int?)?.toString() ?? '';
          _licensePlateController.text = data['vehicle_license_plate'] as String? ?? '';
          _colorController.text = data['vehicle_color'] as String? ?? '';
          _transmissionController.text = data['vehicle_transmission'] as String? ?? '';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _updatePersonalInfo() async {
    try {
      await ApiService.updatePersonalInfo(
        widget.userId,
        _nameController.text,
        _dobController.text,
        _phoneController.text,
        _emergencyContactController.text,
      );
      setState(() => _currentStep = 1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal info updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _updateVehicleInfo() async {
    try {
      await ApiService.updateVehicleInfo(
        widget.userId,
        _makeController.text,
        _modelController.text,
        int.tryParse(_yearController.text) ?? 0,
        _licensePlateController.text,
        _colorController.text,
        _transmissionController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle info updated')),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    _colorController.dispose();
    _transmissionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Stepper(
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        steps: [
          Step(
            title: const Text('Personal Information'),
            content: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  controller: _dobController,
                  decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)'),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                TextField(
                  controller: _emergencyContactController,
                  decoration: const InputDecoration(labelText: 'Emergency Contact'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _updatePersonalInfo,
                  child: const Text('Save & Continue'),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Vehicle Information'),
            content: Column(
              children: [
                TextField(
                  controller: _makeController,
                  decoration: const InputDecoration(labelText: 'Vehicle Make'),
                ),
                TextField(
                  controller: _modelController,
                  decoration: const InputDecoration(labelText: 'Vehicle Model'),
                ),
                TextField(
                  controller: _yearController,
                  decoration: const InputDecoration(labelText: 'Vehicle Year'),
                ),
                TextField(
                  controller: _licensePlateController,
                  decoration: const InputDecoration(labelText: 'License Plate'),
                ),
                TextField(
                  controller: _colorController,
                  decoration: const InputDecoration(labelText: 'Color'),
                ),
                TextField(
                  controller: _transmissionController,
                  decoration: const InputDecoration(labelText: 'Transmission'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _updateVehicleInfo,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
SCREENEOF

echo "✅ Fixed EditProfileScreen"
