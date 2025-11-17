// lib/utils/condition_card.dart

import 'package:flutter/material.dart';

class ConditionUtils {
  static Color getConditionColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'alert':
        return Colors.red;
      case 'normal':
        return Colors.blue; // Assuming normal is blue, adjust as needed
      default:
        return Colors.grey;
    }
  }
}
