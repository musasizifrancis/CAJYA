// Replace _updatePersonalInfo and _updateVehicleInfo methods:

Future<void> _updatePersonalInfo() async {
  try {
    await ApiService.updatePersonalInfo(
      userId: widget.userId,
      fullName: _nameController.text,
      dateOfBirth: _dobController.text,
      phoneNumber: _phoneController.text,
      emergencyContact: _emergencyContactController.text,
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
      userId: widget.userId,
      vehicleMake: _makeController.text,
      vehicleModel: _modelController.text,
      vehicleYear: int.tryParse(_yearController.text) ?? 0,
      vehicleLicensePlate: _licensePlateController.text,
      vehicleColor: _colorController.text,
      vehicleTransmission: _transmissionController.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vehicle info updated')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
