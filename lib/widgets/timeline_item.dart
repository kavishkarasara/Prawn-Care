import 'package:flutter/material.dart';
import 'package:prawn__farm/utils/colors.dart';

import '../models/tracking_data.dart';

// A stateless widget that displays a single item in the order tracking timeline.
class TimelineItem extends StatelessWidget {
  final TrackingData data;

  const TimelineItem({
    super.key,
    required this.data,
  });

  Color getColor() {
    if (data.isCompleted ?? false) return completedGreen;
    if (data.isActive ?? false) return activeAccent;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: getColor(),
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (data.isActive == true)
                      BoxShadow(
                        color: getColor().withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: Icon(
                  data.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(width: 80),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: data.isActive == true ? getColor() : Colors.black87,
                  ),
                ),
                if (data.date.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    data.date,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
