// lib/widgets/pond_condition_card.dart

import 'package:flutter/material.dart';
import '../models/pond_condition.dart';
import '../utils/pond_status_helper.dart';
import 'parameter_tile.dart';

class PondConditionCard extends StatelessWidget {
  final PondCondition? pond; // Make pond nullable

  const PondConditionCard({super.key, required this.pond});

  @override
  Widget build(BuildContext context) {
    if (pond == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final statusColor =
        PondStatusHelper.getStatusColor(pond!.status ?? PondStatus.normal);
    final statusText =
        PondStatusHelper.getStatusText(pond!.status ?? PondStatus.normal);

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: statusColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pond!.pondName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: [
                ParameterTile(
                  icon: Icons.thermostat,
                  label: 'Temp',
                  value: '${pond!.temperature.toStringAsFixed(1)}°C',
                  iconColor: Colors.red.shade400,
                ),
                ParameterTile(
                  icon: Icons.science_outlined,
                  label: 'pH',
                  value: pond!.ph.toStringAsFixed(1),
                  iconColor: Colors.purple.shade400,
                ),
                ParameterTile(
                  icon: Icons.auto_awesome,
                  label: 'Clarity',
                  value: '${pond!.clarity.toStringAsFixed(1)} NTU',
                  iconColor: Colors.blue.shade400,
                ),
                ParameterTile(
                  icon: Icons.water_drop,
                  label: 'Water Level',
                  value: '${pond!.waterLevel.toStringAsFixed(1)} cm',
                  iconColor: Colors.teal.shade400,
                ),
                ParameterTile(
                  icon: Icons.wifi,
                  label: 'IP Address',
                  value: pond!.ipAddress,
                  iconColor: Colors.green.shade400,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.update, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Updated: ${pond!.lastUpdated.hour}:${pond!.lastUpdated.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
