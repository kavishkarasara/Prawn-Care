/// This file defines the UserType model used for user role selection in the app.

import 'package:flutter/material.dart';

/// Represents a user type or role in the application.
/// This model contains UI properties like colors, icons, and the destination screen for each user type.
class UserType {
  /// The display title for this user type.
  final String title;

  /// The background color for the user type card.
  final Color color;

  /// The text color for the user type card.
  final Color textColor;

  /// The icon representing this user type.
  final IconData icon;

  /// The destination widget/screen to navigate to when this user type is selected.
  final Widget destination;

  /// Constructor for UserType.
  const UserType({
    required this.title,
    required this.color,
    required this.textColor,
    required this.icon,
    required this.destination,
  });
}
