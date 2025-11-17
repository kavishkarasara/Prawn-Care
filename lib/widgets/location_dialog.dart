import 'package:flutter/material.dart';

class LocationDialog extends StatelessWidget {
  final VoidCallback onRefresh;
  final Function(String, double, double) onSelectPredefined;

  const LocationDialog({
    super.key,
    required this.onRefresh,
    required this.onSelectPredefined,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Location Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.my_location),
            title: const Text('Use Current Location'),
            subtitle: const Text('Refresh with your live location'),
            onTap: onRefresh,
          ),
          const Divider(),
          const Text('Or select a predefined location:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildPredefinedLocation('Puttalam', 8.0381, 79.8248),
                _buildPredefinedLocation('Jaffna', 9.6615, 80.0255),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildPredefinedLocation(String name, double lat, double lon) {
    return ListTile(
      leading: const Icon(Icons.location_on),
      title: Text(name),
      onTap: () => onSelectPredefined(name, lat, lon),
    );
  }
}
