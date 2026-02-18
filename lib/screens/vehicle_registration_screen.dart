import 'package:flutter/material.dart';

class VehicleDetailsScreen extends StatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _plateController;
  late TextEditingController _vinController;
  
  String? _selectedColor;
  String? _selectedFuelType;

  @override
  void initState() {
    super.initState();
    _makeController = TextEditingController();
    _modelController = TextEditingController();
    _yearController = TextEditingController();
    _plateController = TextEditingController();
    _vinController = TextEditingController();
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Details'),
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
              const Text(
                'Tell us about your vehicle',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              
              _buildTextField('Vehicle Make *', 'e.g., Toyota', _makeController),
              const SizedBox(height: 16),
              
              _buildTextField('Vehicle Model *', 'e.g., Corolla', _modelController),
              const SizedBox(height: 16),
              
              _buildTextField('Year *', 'e.g., 2020', _yearController, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              
              _buildTextField('License Plate *', 'Enter plate number', _plateController),
              const SizedBox(height: 16),
              
              _buildTextField('VIN (Optional)', 'Vehicle Identification Number', _vinController),
              const SizedBox(height: 16),
              
              _buildDropdown('Vehicle Color *', 'Select color', _selectedColor,
                ['Black', 'White', 'Silver', 'Red', 'Blue', 'Gray', 'Other'],
                (val) => setState(() => _selectedColor = val)),
              const SizedBox(height: 16),
              
              _buildDropdown('Fuel Type *', 'Select fuel type', _selectedFuelType,
                ['Petrol', 'Diesel', 'Hybrid', 'Electric'],
                (val) => setState(() => _selectedFuelType = val)),
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
                      Navigator.pushNamed(context, '/dashboard');
                    }
                  },
                  child: const Text(
                    'COMPLETE SETUP',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          validator: (v) {
            if (label.contains('*') && (v?.isEmpty ?? true)) return 'Required';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String hint,
    String? value,
    List<String> items,
    Function(String?) onChange,
  ) {
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
