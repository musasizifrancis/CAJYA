import 'package:flutter/material.dart';

class DriverProfileScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;
  
  const DriverProfileScreen({
    super.key,
    this.initialData = const {},
  });

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  
  String? _selectedGender;
  String? _selectedDocumentType;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.initialData['fullName'] ?? '');
    _phoneController = TextEditingController(text: widget.initialData['phone'] ?? '');
    _addressController = TextEditingController(text: widget.initialData['address'] ?? '');
    _cityController = TextEditingController(text: widget.initialData['city'] ?? '');
    _selectedGender = widget.initialData['gender'];
    _selectedDocumentType = widget.initialData['documentType'];
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        backgroundColor: const Color(0xFF001a4d),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildTextField('Full Name *', 'Enter full name', _fullNameController),
              const SizedBox(height: 16),
              _buildTextField('Phone *', 'Enter phone number', _phoneController),
              const SizedBox(height: 16),
              _buildDropdown('Gender *', 'Select gender', _selectedGender, 
                ['Male', 'Female', 'Other'], 
                (val) => setState(() => _selectedGender = val)),
              const SizedBox(height: 16),
              _buildTextField('Address *', 'Enter address', _addressController, maxLines: 2),
              const SizedBox(height: 16),
              _buildTextField('City *', 'Enter city', _cityController),
              const SizedBox(height: 16),
              _buildDropdown('ID Type *', 'Select ID type', _selectedDocumentType,
                ['National ID', 'Passport', 'Driver License'],
                (val) => setState(() => _selectedDocumentType = val)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003d99),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pushNamed(context, '/vehicle-details');
                    }
                  },
                  child: const Text('CONTINUE', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String hint, String? value, List<String> items, Function(String?) onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChange,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          validator: (v) => v == null ? 'Required' : null,
        ),
      ],
    );
  }
}
