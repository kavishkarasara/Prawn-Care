import 'package:flutter/material.dart';

// Defines a custom purple color for branding
const Color brandPurple = Color(0xFF6366F1);

// Defines the accent color for active items
const Color activeAccent = Color(0xFF6C63FF);

// Defines the color for completed items
const Color completedGreen = Colors.green;

// Defines the primary color for reuse.
const Color primaryColor = Color(0xFF6366F1);

class AppColors {
  static Color getCardColor(DateTime scheduledTime) {
    DateTime now = DateTime.now();
    Duration difference = scheduledTime.difference(now);

    if (difference.isNegative || difference.inMinutes > 10) {
      return Colors.lightBlue.shade100; // Others - light blue
    } else if (difference.inMinutes <= 10) {
      return Colors.red.shade100; // Due soon (within 10 minutes) - red
    } else {
      return Colors.grey.shade300; // Normal (shouldn't reach here)
    }
  }

  static Color getTimeColor(DateTime scheduledTime) {
    DateTime now = DateTime.now();
    Duration difference = scheduledTime.difference(now);

    if (difference.isNegative || difference.inMinutes > 10) {
      return Colors.lightBlue.shade700; // Others - light blue
    } else if (difference.inMinutes <= 10) {
      return Colors.red.shade700; // Due soon (within 10 minutes) - red
    } else {
      return Colors.black; // Normal (shouldn't reach here)
    }
  }

  // Check if feeding is due soon (within 10 minutes)
  static bool isDueSoon(DateTime scheduledTime) {
    DateTime now = DateTime.now();
    Duration difference = scheduledTime.difference(now);
    return !difference.isNegative && difference.inMinutes <= 10;
  }

  // Check if feeding is overdue
  static bool isOverdue(DateTime scheduledTime) {
    DateTime now = DateTime.now();
    Duration difference = scheduledTime.difference(now);
    return difference.isNegative;
  }
}
