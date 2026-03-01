import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class DriverProfileSetupScreen extends StatefulWidget {
  final String email;

  const DriverProfileSetupScreen({
    required this.email,
    super.key,
  });

  @override
  State<DriverProfileSetupScreen> createState() =>
      _DriverProfileSetupScreenState();
}

class _DriverProfileSetupScreenState extends State<DriverProfileSetupScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: Personal Information
  late TextEditingController fullNameController;
  late TextEditingController nationalIdController;
  late TextEditingController dateOfBirthController;
  late TextEditingController phoneController;
  late TextEditingController emergencyContactController;

  // Step 2: Vehicle Information
  String? selectedVehicleMake;
  late TextEditingController vehicleModelController;
  String? selectedVehicleYear;
  late TextEditingController licensePlateController;
  late TextEditingController vehicleColorController;
  String? selectedTransmission = 'Manual';

  // Step 3: Documents
  String? driverLicenseFrontPath;
  String? driverLicenseBackPath;
  String? vehicleRegistrationPath;
  String? insuranceDocumentPath;
  late TextEditingController licenseExpiryController;

  // Step 4: Payment Setup
  late TextEditingController mtnNumberController;
  late TextEditingController mtnNameController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    fullNameController = TextEditingController();
    nationalIdController = TextEditingController();
    dateOfBirthController = TextEditingController();
    phoneController = TextEditingController();
    emergencyContactController = TextEditingController();
    vehicleModelController = TextEditingController();
    licensePlateController = TextEditingController();
    vehicleColorController = TextEditingController();
    licenseExpiryController = TextEditingController();
    mtnNumberController = TextEditingController();
    mtnNameController = TextEditingController();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    nationalIdController.dispose();
    dateOfBirthController.dispose();
    phoneController.dispose();
    emergencyContactController.dispose();
    vehicleModelController.dispose();
    licensePlateController.dispose();
    vehicleColorController.dispose();
    licenseExpiryController.dispose();
    mtnNumberController.dispose();
    mtnNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep == 0
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF001a4d)),
                onPressed: _previousStep,
              ),
        title: const Text(
          'Complete Your Profile',
          style: TextStyle(
            color: Color(0xFF001a4d),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepIndicator(),
            const SizedBox(height: 32),
            _buildStepContent(),
            const SizedBox(height: 32),
            _buildNavigationButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final stepTitles = [
      'Personal Info',
      'Vehicle Details',
      'Documents',
      'Payment Setup'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STEP ${_currentStep + 1} OF 4: ${stepTitles[_currentStep].toUpperCase()}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            minHeight: 4,
            backgroundColor: const Color(0xFFE0E0E0),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF003d99)),
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildVehicleInfoStep();
      case 2:
        return _buildDocumentsStep();
      case 3:
        return _buildPaymentSetupStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF001a4d),
          ),
        ),
        const SizedBox(height: 20),
        _buildFormField('Full Name', fullNameController, Icons.person),
        const SizedBox(height: 16),
        _buildFormField('National ID', nationalIdController, Icons.badge),
        const SizedBox(height: 16),
        _buildDateField('Date of Birth', dateOfBirthController),
        const SizedBox(height: 16),
        _buildFormField('Phone Number', phoneController, Icons.phone),
        const SizedBox(height: 16),
        _buildFormField('Emergency Contact', emergencyContactController,
            Icons.phone_in_talk),
      ],
    );
  }

  Widget _buildVehicleInfoStep() {
    final vehicleMakes = [
      'Toyota',
      'Honda',
      'Nissan',
      'Mazda',
      'Volkswagen',
      'Ford',
      'BMW',
      'Mercedes',
      'Hyundai',
      'Kia',
      'Other'
    ];
    final years = List.generate(12, (index) => (2026 - index).toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vehicle Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF001a4d),
          ),
        ),
        const SizedBox(height: 20),
        _buildDropdownField('Vehicle Make', vehicleMakes, selectedVehicleMake,
            (value) {
          setState(() => selectedVehicleMake = value);
        }),
        const SizedBox(height: 16),
        _buildFormField('Vehicle Model', vehicleModelController,
            Icons.directions_car),
        const SizedBox(height: 16),
        _buildDropdownField('Vehicle Year', years, selectedVehicleYear, (value) {
          setState(() => selectedVehicleYear = value);
        }),
        const SizedBox(height: 16),
        _buildFormField('License Plate', licensePlateController,
            Icons.credit_card),
        const SizedBox(height: 16),
        _buildFormField('Vehicle Color', vehicleColorController,
            Icons.palette),
        const SizedBox(height: 16),
        _buildDropdownField(
          'Transmission',
          ['Manual', 'Automatic'],
          selectedTransmission,
          (value) {
            setState(() => selectedTransmission = value);
          },
        ),
      ],
    );
  }

  Widget _buildDocumentsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Documents',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF001a4d),
          ),
        ),
        const SizedBox(height: 20),
        _buildDocumentUploadArea(
          'Driver\'s License (Front)',
          driverLicenseFrontPath,
          () => _pickDocument((path) =>
              setState(() => driverLicenseFrontPath = path)),
        ),
        const SizedBox(height: 16),
        _buildDocumentUploadArea(
          'Driver\'s License (Back)',
          driverLicenseBackPath,
          () => _pickDocument((path) =>
              setState(() => driverLicenseBackPath = path)),
        ),
        const SizedBox(height: 16),
        _buildDocumentUploadArea(
          'Vehicle Registration',
          vehicleRegistrationPath,
          () => _pickDocument((path) =>
              setState(() => vehicleRegistrationPath = path)),
        ),
        const SizedBox(height: 16),
        _buildDocumentUploadArea(
          'Insurance Document',
          insuranceDocumentPath,
          () => _pickDocument((path) =>
              setState(() => insuranceDocumentPath = path)),
        ),
        const SizedBox(height: 16),
        _buildDateField('License Expiry Date', licenseExpiryController),
      ],
    );
  }

  Widget _buildPaymentSetupStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Setup (Optional)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF001a4d),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Add your MTN Mobile Money details to receive payments. You can complete this later.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 20),
        _buildFormField(
          'MTN Mobile Money Number',
          mtnNumberController,
          Icons.phone,
          hint: '+256 xxx xxx xxx',
        ),
        const SizedBox(height: 16),
        _buildFormField(
          'Account Name',
          mtnNameController,
          Icons.person,
          hint: 'Name on account',
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            border: Border.all(color: const Color(0xFFE0E8FF)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.info, color: Color(0xFF003d99), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your payment details will be verified before you can withdraw.',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF003d99),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    IconData icon, {
    String? hint,
    bool isPassword = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF001a4d),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF003d99), size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF003d99), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF001a4d),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_today,
                color: Color(0xFF003d99), size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF003d99), width: 2),
            ),
          ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              controller.text = DateFormat('yyyy-MM-dd').format(picked);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF001a4d),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedValue,
            hint: Text(label),
            onChanged: onChanged,
            items: items
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(item),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUploadArea(
    String label,
    String? uploadedFileName,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF001a4d),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: uploadedFileName != null
                    ? const Color(0xFF27ae60)
                    : const Color(0xFFE0E0E0),
              ),
              borderRadius: BorderRadius.circular(8),
              color: uploadedFileName != null
                  ? const Color(0xFFF0FFF4)
                  : Colors.white,
            ),
            child: Column(
              children: [
                if (uploadedFileName == null)
                  const Icon(Icons.cloud_upload,
                      color: Color(0xFF003d99), size: 32)
                else
                  const Icon(Icons.check_circle,
                      color: Color(0xFF27ae60), size: 32),
                const SizedBox(height: 8),
                Text(
                  uploadedFileName ?? 'Tap to upload',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: uploadedFileName != null
                        ? const Color(0xFF27ae60)
                        : const Color(0xFF666666),
                    fontWeight: uploadedFileName != null
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF003d99)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'BACK',
                style: TextStyle(
                  color: Color(0xFF003d99),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF001a4d),
              disabledBackgroundColor: const Color(0xFFCCCCCC),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _currentStep < 3 ? 'NEXT' : 'COMPLETE PROFILE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _nextStep() async {
    if (_validateCurrentStep()) {
      if (_currentStep < 3) {
        setState(() => _currentStep++);
      } else {
        await _saveProfile();
      }
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (fullNameController.text.isEmpty ||
            nationalIdController.text.isEmpty ||
            dateOfBirthController.text.isEmpty ||
            phoneController.text.isEmpty) {
          _showSnackBar('Please fill in all fields');
          return false;
        }
        return true;
      case 1:
        if (selectedVehicleMake == null ||
            vehicleModelController.text.isEmpty ||
            selectedVehicleYear == null ||
            licensePlateController.text.isEmpty ||
            vehicleColorController.text.isEmpty) {
          _showSnackBar('Please fill in all vehicle details');
          return false;
        }
        return true;
      case 2:
        if (driverLicenseFrontPath == null ||
            driverLicenseBackPath == null ||
            vehicleRegistrationPath == null ||
            insuranceDocumentPath == null ||
            licenseExpiryController.text.isEmpty) {
          _showSnackBar('Please upload all required documents');
          return false;
        }
        return true;
      case 3:
        return true;
    }
    return false;
  }

  Future<void> _pickDocument(Function(String) onPicked) async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Show bottom sheet to pick source
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Document Source',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF003d99)),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  await _captureDocument(picker, onPicked);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Color(0xFF003d99)),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFromGallery(picker, onPicked);
                },
              ),
              ListTile(
                leading: const Icon(Icons.description, color: Color(0xFF003d99)),
                title: const Text('Choose File'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFile(onPicked);
                },
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      _showSnackBar('Error opening file picker: $e');
    }
  }

  Future<void> _captureDocument(
    ImagePicker picker,
    Function(String) onPicked,
  ) async {
    try {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        await _uploadDocument(File(photo.path), onPicked);
      }
    } catch (e) {
      _showSnackBar('Error capturing photo: $e');
    }
  }

  Future<void> _pickFromGallery(
    ImagePicker picker,
    Function(String) onPicked,
  ) async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        await _uploadDocument(File(image.path), onPicked);
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  Future<void> _pickFile(Function(String) onPicked) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final PlatformFile file = result.files.first;
        if (file.path != null) {
          await _uploadDocument(File(file.path!), onPicked);
        }
      }
    } catch (e) {
      _showSnackBar('Error picking file: $e');
    }
  }

  Future<void> _uploadDocument(
    File file,
    Function(String) onPicked,
  ) async {
    try {
      // Show loading dialog
      _showLoadingDialog('Validating and uploading...');

      // Validate file
      final validationError = _validateDocument(file);
      if (validationError != null) {
        Navigator.pop(context); // Close loading dialog
        _showSnackBar(validationError);
        return;
      }

      // Get user ID
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        Navigator.pop(context);
        _showSnackBar('User not authenticated');
        return;
      }

      // Upload to Supabase Storage
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final filePath = 'driver-documents/\$userId/\$fileName';

      final fileBytes = await file.readAsBytes();
      await Supabase.instance.client.storage.from('driver-documents').uploadBinary(
            filePath,
            fileBytes,
          );

      // Close loading dialog
      Navigator.pop(context);

      // Callback with file name
      onPicked(file.path.split('/').last);

      _showSnackBar('Document uploaded successfully!');
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showSnackBar('Error uploading document: \$e');
    }
  }

  String? _validateDocument(File file) {
    // Check file size (max 10MB)
    final fileSize = file.lengthSync();
    const maxSize = 10 * 1024 * 1024; // 10MB
    if (fileSize > maxSize) {
      return 'File size exceeds 10MB limit';
    }

    // Check file type
    final fileName = file.path.toLowerCase();
    final validExtensions = ['.jpg', '.jpeg', '.png', '.pdf'];
    final isValidType =
        validExtensions.any((ext) => fileName.endsWith(ext));

    if (!isValidType) {
      return 'Only JPG, PNG, and PDF files are allowed';
    }

    return null; // No error
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF003d99),
              ),
            ),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      final profileData = {
        'full_name': fullNameController.text,
        'national_id': nationalIdController.text,
        'date_of_birth': dateOfBirthController.text,
        'phone': phoneController.text,
        'emergency_contact': emergencyContactController.text,
        'vehicle_make': selectedVehicleMake,
        'vehicle_model': vehicleModelController.text,
        'vehicle_year': selectedVehicleYear,
        'license_plate': licensePlateController.text,
        'vehicle_color': vehicleColorController.text,
        'transmission_type': selectedTransmission,
        'license_expiry_date': licenseExpiryController.text,
      };

      if (mtnNumberController.text.isNotEmpty) {
        profileData['mtn_number'] = mtnNumberController.text;
        profileData['mtn_account_name'] = mtnNameController.text;
      }

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        _showSnackBar('User not authenticated');
        return;
      }
      await ApiService.completeDriverProfile(userId, profileData);

      if (!mounted) return;

      _showSnackBar('Profile completed successfully!');

      Navigator.pushReplacementNamed(
        context,
        '/driver-dashboard',
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error saving profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF001a4d),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
