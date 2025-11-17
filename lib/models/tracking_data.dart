/// This file contains the TrackingData model used for order tracking functionality.

import 'package:flutter/src/widgets/icon_data.dart';

import 'order_status.dart';

/// Represents a single tracking entry for an order's progress.
/// This model holds the title, date, and status of a tracking step, with computed properties for UI display.
class TrackingData {
  /// The title or description of the tracking step.
  final String title;

  /// The date when this tracking step occurred or is expected.
  final String date;

  /// The status of this tracking step.
  final OrderStatus status;

  /// Constructor for TrackingData.
  TrackingData({
    required this.title,
    required this.date,
    required this.status,
  });

  /// Indicates whether this tracking step is completed.
  /// Currently returns null, suggesting this should be implemented based on status.
  bool? get isCompleted => null;

  /// Indicates whether this tracking step is currently active.
  /// Currently returns null, suggesting this should be implemented based on status.
  bool? get isActive => null;

  /// The icon associated with this tracking step.
  /// Currently returns null, suggesting this should be implemented based on status.
  IconData? get icon => null;
}
