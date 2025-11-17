// lib/screens/feeding_schedule/widgets/add_feeding_dialog.dart

import 'package:flutter/material.dart';
import '../../../utils/colors.dart';

class AddFeedingDialog extends StatefulWidget {
  const AddFeedingDialog({super.key});

  @override
  State<AddFeedingDialog> createState() => _AddFeedingDialogState();
}

class _AddFeedingDialogState extends State<AddFeedingDialog> {
  String _tankName = '';
  TimeOfDay _selectedTime = TimeOfDay.now();

  void _presentTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitData() {
    if (_tankName.isNotEmpty) {
      Navigator.of(context).pop({
        'tankName': _tankName,
        'time': _selectedTime,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Feeding Schedule'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Tank Name',
              hintText: 'e.g., Tank 5- Hatchery Feed',
            ),
            onChanged: (value) {
              _tankName = value;
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Time: '),
              TextButton(
                onPressed: _presentTimePicker,
                child: Text(
                  '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitData,
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          child: const Text('Add', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
