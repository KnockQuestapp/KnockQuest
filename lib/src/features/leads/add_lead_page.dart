import 'package:flutter/material.dart';

import '../../services/lead_service.dart';

class AddLeadPage extends StatefulWidget {
  const AddLeadPage({super.key});

  @override
  State<AddLeadPage> createState() => _AddLeadPageState();
}

class _AddLeadPageState extends State<AddLeadPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _unitNumber = TextEditingController();
  final _city = TextEditingController();
  final _postalCode = TextEditingController();
  final _notes = TextEditingController();
  final _latitude = TextEditingController(text: '40.7128');
  final _longitude = TextEditingController(text: '-74.0060');
  final _lastContactDate = TextEditingController(text: '2026-08-04');
  final _followUpDate = TextEditingController(text: '2026-08-11');

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _unitNumber.dispose();
    _city.dispose();
    _postalCode.dispose();
    _notes.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _lastContactDate.dispose();
    _followUpDate.dispose();
    super.dispose();
  }

  Future<void> _saveLead() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final fullName = '${_firstName.text.trim()} ${_lastName.text.trim()}'.trim();
      final address = [
        _address.text.trim(),
        _unitNumber.text.trim(),
        _city.text.trim(),
        _postalCode.text.trim(),
      ].where((s) => s.isNotEmpty).join(', ');

      final lead = await LeadService().createLead(
        name: fullName.isNotEmpty ? fullName : _firstName.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim(),
        address: address.isNotEmpty ? address : null,
        latitude: double.tryParse(_latitude.text.trim()),
        longitude: double.tryParse(_longitude.text.trim()),
        notes: _notes.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead saved successfully!')),
      );

      Navigator.pop(context, lead);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 52, 16, 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Text(
                      'Add Lead',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _FormLine(
                            label: 'First Name',
                            controller: _firstName,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'First name is required';
                              }
                              return null;
                            },
                          ),
                          _FormLine(label: 'Last Name', controller: _lastName),
                          _FormLine(
                            label: 'Phone',
                            controller: _phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Phone is required';
                              }
                              return null;
                            },
                          ),
                          _FormLine(
                            label: 'Email',
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          _FormLine(label: 'Address', controller: _address),
                          _FormLine(label: 'Unit Number', controller: _unitNumber),
                          _FormLine(label: 'City', controller: _city),
                          _FormLine(label: 'Postal Code', controller: _postalCode),
                          _FormLine(label: 'Notes', controller: _notes, maxLines: 3),
                          _FormLine(
                            label: 'Latitude',
                            controller: _latitude,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                          _FormLine(
                            label: 'Longitude',
                            controller: _longitude,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                          _FormLine(
                            label: 'Last Contact Date',
                            controller: _lastContactDate,
                          ),
                          _FormLine(
                            label: 'Follow Up Date',
                            controller: _followUpDate,
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton(
                              onPressed: _saveLead,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              ),
                              child: const Text('Save Lead'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormLine extends StatelessWidget {
  const _FormLine({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            decoration: const InputDecoration(
              isDense: true,
              border: UnderlineInputBorder(),
              contentPadding: EdgeInsets.only(bottom: 8),
            ),
          ),
        ],
      ),
    );
  }
}
