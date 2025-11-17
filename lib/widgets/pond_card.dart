import 'package:flutter/material.dart';
import 'package:prawn__farm/models/pond_condition.dart';

class PondCard extends StatelessWidget {
  final PondCondition pond;
  final VoidCallback onViewDetails;
  final VoidCallback onRefresh;

  const PondCard({
    super.key,
    required this.pond,
    required this.onViewDetails,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pond.pondName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: pond.isConnected ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pond.isConnected ? 'Connected' : 'Disconnected',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IP: ${pond.ipAddress}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricItem(
                        'Temp', '${pond.temperature.toStringAsFixed(1)}°C'),
                    _buildMetricItem(
                        'Clarity', '${pond.clarity.toStringAsFixed(1)} NTU'),
                    _buildMetricItem('pH', pond.ph.toStringAsFixed(1)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onViewDetails,
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onRefresh,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text('Refresh'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    IconData iconData;
    Color iconColor;

    switch (label.toLowerCase()) {
      case 'temp':
      case 'temperature':
        iconData = Icons.thermostat;
        iconColor = Colors.red.shade400;
        break;
      case 'clarity':
        iconData = Icons.auto_awesome;
        iconColor = Colors.blue.shade400;
        break;
      case 'o2':
        iconData = Icons.air;
        iconColor = Colors.blue.shade400;
        break;
      case 'ammonia':
      case 'nh3':
        iconData = Icons.warning_amber_rounded;
        iconColor = Colors.brown.shade400;
        break;
      case 'ph':
        iconData = Icons.science_outlined;
        iconColor = Colors.purple.shade400;
        break;
      default:
        iconData = Icons.info_outline;
        iconColor = Colors.grey;
    }

    return Column(
      children: [
        Icon(iconData, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
