import 'package:flutter/material.dart';

// Spacing
const double kPaddingHorizontal = 20.0;
const double kSpacingSmall = 8.0;
const double kSpacingMedium = 16.0;
const double kSpacingLarge = 20.0;

// Border styles for form fields
final kInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(20),
  borderSide: const BorderSide(color: Colors.grey, width: 1.5),
);
final kInputFocusedBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(20),
  borderSide: const BorderSide(color: Colors.blue, width: 2.5),
);
final kInputErrorBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(20),
  borderSide: const BorderSide(color: Colors.red, width: 1.5),
);

// Colors
const Color kPrimaryColor = Colors.blue;
const Color kSecondaryColor = Color(0xFF90CAF9); // Blue 200
const Color kWhiteColor = Colors.white;
const Color kBlackColor = Colors.black;

// This file defines all the colors used in the app for consistency.
class AppColors {
  static const Color primary = Colors.blue;
  static const Color accent = Color(0xFF2196F3); // Blue accent
  static const Color icon = Color(0xFF2196F3); // Blue icon
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color darkBlue = Color(0xFF1976D2);
  static const Color background = Color(0xFFE3F2FD); // Light blue background
  static const Color surface = Color(0xFFBBDEFB); // Blue surface
}

const String API_KEY = '588e6ed46419de94b93e75fda84ce989';
const String BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';

// Backend base URL for authentication and other API calls
const String BACKEND_BASE_URL = 'http://192.168.1.74:5000';
