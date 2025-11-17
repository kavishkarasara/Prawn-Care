String? validateUserNameOrEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your Username or Email';
  }
  if (value.length < 4) {
    return 'Username or Email must be at least 4 characters';
  }
  // Basic email validation if it contains @
  if (value.contains('@') && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}

String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your name';
  }
  return null;
}

String? validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your phone number';
  }
  // Simple phone validation - adjust based on your requirements
  if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
    return 'Please enter a valid phone number';
  }
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  if (value == null || value.isEmpty) {
    return 'Please confirm your password';
  }
  if (value != password) {
    return 'Passwords do not match';
  }
  return null;
}
