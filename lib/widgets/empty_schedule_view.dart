// lib/screens/feeding_schedule/widgets/empty_schedule_view.dart

import 'package:flutter/material.dart';

class EmptyScheduleView extends StatelessWidget {
  const EmptyScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            'No feeding schedules',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap + to add a new feeding schedule',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
