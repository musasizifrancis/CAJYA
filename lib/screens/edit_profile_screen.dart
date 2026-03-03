import 'package:flutter/material.dart';
import 'package:cajya/services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String driverId;
  late String _userId = '';

  EditProfileScreen({
    Key? key,
    required this.driverId,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  int _currentStep = 0;
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emergencyContactController =
      TextEditingController();

  final TextEditingController _vehicleMakeController = TextEditingController();
  final TextEditingController _vehicleModelController =
      TextEditingController();
  final TextEditingController _vehicleYearController = TextEditingController();
  final TextEditingController _licensePlateController =
      TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _transmissionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final data = await ApiService.getDriverProfile(widget.driverId);
      if (data != null) {
        widget._userId = data['user_id'] ?? '';
        setState(() {
          _nameController.text = data['full_name'] as String? ?? '';
          _dobController.text = data['date_of_birth'] as String? ?? '';
          _phoneController.text = data['phone_number'] as String? ?? '';
          _emergencyContactController.text =
              data['emergency_contact'] as String? ?? '';
          _vehicleMakeController.text = data['vehicle_make'] as String? ?? '';
          _vehicleModelController.text =
              data['vehicle_model'] as String? ?? '';
          _vehicleYearController.text = data['vehicle_year'] as String? ?? '';
          _licensePlateController.text =
              data['license_plate'] as String? ?? '';
          _colorController.text = data['vehicle_color'] as String? ?? '';
          _transmissionController.text =
              data['transmission_type'] as String? ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePersonalInfo() async {
    try {
      await ApiService.updatePersonalInfo(
        userId: widget._userId,
        fullName: _nameController.text,
        dateOfBirth: _dobController.text,
        phoneNumber: _phoneController.text,
        emergencyContact: _emergencyContactController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Personal info updated successfully')),
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
        userId: widget._userId,
        vehicleMake: _vehicleMakeController.text,
        vehicleModel: _vehicleModelController.text,
        vehicleYear: int.parse(_vehicleYearController.text),
        vehicleLicensePlate: _licensePlateController.text,
        vehicleColor: _colorController.text,
        vehicleTransmission: _transmissionController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle info updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          backgroundColor: const Color(0xFF1E88E5),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0) {
            _updatePersonalInfo();
            setState(() => _currentStep = 1);
          } else {
            _updateVehicleInfo();
            Navigator.pop(context);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          } else {
            Navigator.pop(context);
          }
        },
        steps: [
          Step(
            title: const Text('Personal Information'),
            isActive: _currentStep >= 0,
            content: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  controller: _dobController,
                  decoration:
                      const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)'),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                TextField(
                  controller: _emergencyContactController,
                  decoration:
                      const InputDecoration(labelText: 'Emergency Contact'),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Vehicle Information'),
            isActive: _currentStep >= 1,
            content: Column(
              children: [
                TextField(
                  controller: _vehicleMakeController,
                  decoration: const InputDecoration(labelText: 'Vehicle Make'),
                ),
                TextField(
                  controller: _vehicleModelController,
                  decoration:
                      const InputDecoration(labelText: 'Vehicle Model'),
                ),
                TextField(
                  controller: _vehicleYearController,
                  decoration: const InputDecoration(labelText: 'Vehicle Year'),
                ),
                TextField(
                  controller: _licensePlateController,
                  decoration:
                      const InputDecoration(labelText: 'License Plate'),
                ),
                TextField(
                  controller: _colorController,
                  decoration: const InputDecoration(labelText: 'Color'),
                ),
                TextField(
                  controller: _transmissionController,
                  decoration:
                      const InputDecoration(labelText: 'Transmission Type'),
                ),
              ],
            ),
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
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _licensePlateController.dispose();
    _colorController.dispose();
    _transmissionController.dispose();
    super.dispose();
  }
}
