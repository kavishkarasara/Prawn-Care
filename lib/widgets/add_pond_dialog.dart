import 'package:flutter/material.dart';
import '../services/pond_service.dart';

class AddPondDialog extends StatefulWidget {
  const AddPondDialog({super.key});

  @override
  State<AddPondDialog> createState() => _AddPondDialogState();
}

class _AddPondDialogState extends State<AddPondDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pondNameController = TextEditingController();
  final _ipAddressController = TextEditingController();
  final _phIpAddressController = TextEditingController();
  final PondService _pondService = PondService();

  @override
  void dispose() {
    _pondNameController.dispose();
    _ipAddressController.dispose();
    _phIpAddressController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final pondId = 'pond${_pondService.ponds.length + 1}';
        await _pondService.addPondWithIp(
          _pondNameController.text.trim(),
          _ipAddressController.text.trim(),
          _phIpAddressController.text.trim(),
        );
        Navigator.of(context).pop(pondId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pond added successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add pond: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Pond'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _pondNameController,
              decoration: const InputDecoration(
                labelText: 'Pond Name',
                hintText: 'Enter pond name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a pond name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ipAddressController,
              decoration: const InputDecoration(
                labelText: 'IP Address (Temp, Clarity, Water Level)',
                hintText: 'Enter IP address (e.g., 10.106.36.55)',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an IP address';
                }
                // Basic IP address validation
                final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
                if (!ipRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid IP address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phIpAddressController,
              decoration: const InputDecoration(
                labelText: 'pH IP Address',
                hintText: 'Enter pH sensor IP address (e.g., 10.106.36.56)',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a pH IP address';
                }
                // Basic IP address validation
                final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
                if (!ipRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid IP address';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Add Pond'),
        ),
      ],
    );
  }
}
