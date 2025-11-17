import 'package:flutter/material.dart';
import 'package:prawn__farm/models/pond_condition.dart';

class PondDetailsDialogWidget extends StatelessWidget {
  final PondCondition pond;

  const PondDetailsDialogWidget({
    super.key,
    required this.pond,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(pond.pondName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('IP Address: ${pond.ipAddress}'),
          Text('Temperature: ${pond.temperature.toStringAsFixed(1)}°C'),
          Text('Oxygen: ${pond.dissolvedOxygen.toStringAsFixed(1)} mg/L'),
          Text('pH: ${pond.ph.toStringAsFixed(1)}'),
          Text('Water Level: ${pond.waterLevel.toStringAsFixed(1)} cm'),
          Text('Status: ${pond.status?.name ?? 'Unknown'}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
