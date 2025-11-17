// lib/utils/pond_status_helper.dart

import 'package:flutter/material.dart';
import '../models/pond_condition.dart';

class PondStatusHelper {
  static Color getStatusColor(PondStatus status) {
    switch (status) {
      case PondStatus.good:
        return Colors.green;
      case PondStatus.warning:
        return Colors.orange;
      case PondStatus.alert:
        return Colors.red;
      case PondStatus.normal:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  static String getStatusText(PondStatus status) {
    switch (status) {
      case PondStatus.good:
        return 'Good';
      case PondStatus.warning:
        return 'Warning';
      case PondStatus.alert:
        return 'Alert';
      case PondStatus.normal:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
