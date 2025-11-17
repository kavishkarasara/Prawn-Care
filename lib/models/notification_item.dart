import 'package:flutter/material.dart';

/// Represents a notification item displayed in the app.
/// This model holds the icon, color, title, message, time, and read status of a notification.
class NotificationItem {
  /// The icon to display for the notification.
  final IconData icon;

  /// The color of the icon.
  final Color iconColor;

  /// The title of the notification.
  final String title;

  /// The message content of the notification.
  final String message;

  /// The time when the notification was sent or received.
  final String time;

  /// Indicates whether the notification has been read.
  bool isRead;

  /// Constructor for NotificationItem.
  NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });
}
