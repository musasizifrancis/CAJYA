import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _apiService = ApiService();
  late String _userId;
  int _currentStep = 0;
  bool _isLoading = true;

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
    _userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final data = await ApiService.getDriverProfile(_userId);
      if (mounted) {
        setState(() {
          _nameController.text = data['full_name'] ?? '';
          _dobController.text = data['date_of_birth'] ?? '';
          _phoneController.text = data['phone_number'] ?? '';
          _emergencyContactController.text = data['emergency_contact'] ?? '';
          _makeController.text = data['vehicle_make'] ?? '';
          _modelController.text = data['vehicle_model'] ?? '';
          _yearController.text = data['vehicle_year']?.toString() ?? '';
          _licensePlateController.text = data['vehicle_license_plate'] ?? '';
          _colorController.text = data['vehicle_color'] ?? '';
          _transmissionController.text = data['vehicle_transmission'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updatePersonalInfo() async {
    try {
      await ApiService.updatePersonalInfo(
        userId: _userId,
        fullName: _nameController.text,
        dateOfBirth: _dobController.text,
        phoneNumber: _phoneController.text,
        emergencyContact: _emergencyContactController.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Personal info updated successfully!')),
        );
        setState(() => _currentStep = 1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  Future<void> _updateVehicleInfo() async {
    try {
      await ApiService.updateVehicleInfo(
        userId: _userId,
        vehicleMake: _makeController.text,
        vehicleModel: _modelController.text,
        vehicleYear: int.tryParse(_yearController.text) ?? 0,
        vehicleLicensePlate: _licensePlateController.text,
        vehicleColor: _colorController.text,
        vehicleTransmission: _transmissionController.text,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle info updated successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating vehicle info: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
      ),
      body: Stepper(
        currentStep: _currentStep,
        steps: [
          Step(
            title: const Text('Personal Information'),
            content: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _dobController,
                  decoration: const InputDecoration(labelText: 'Date of Birth'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emergencyContactController,
                  decoration: const InputDecoration(labelText: 'Emergency Contact'),
                ),
              ],
            ),
            onStepContinue: _updatePersonalInfo,
          ),
          Step(
            title: const Text('Vehicle Information'),
            content: Column(
              children: [
                TextField(
                  controller: _makeController,
                  decoration: const InputDecoration(labelText: 'Make'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _modelController,
                  decoration: const InputDecoration(labelText: 'Model'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _yearController,
                  decoration: const InputDecoration(labelText: 'Year'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _licensePlateController,
                  decoration: const InputDecoration(labelText: 'License Plate'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _colorController,
                  decoration: const InputDecoration(labelText: 'Color'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _transmissionController,
                  decoration: const InputDecoration(labelText: 'Transmission'),
                ),
              ],
            ),
            onStepContinue: _updateVehicleInfo,
          ),
        ],
      ),
    );
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
}
