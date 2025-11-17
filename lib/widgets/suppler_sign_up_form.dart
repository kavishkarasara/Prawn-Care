import 'package:flutter/material.dart';
import 'package:prawn__farm/utils/constants.dart';

class SupplierSignupForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onRegisterPressed;

  const SupplierSignupForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onRegisterPressed,
  });

  @override
  _SupplierSignupFormState createState() => _SupplierSignupFormState();
}

class _SupplierSignupFormState extends State<SupplierSignupForm> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: kSpacingMedium),
        _buildTextField(
          controller: widget.nameController,
          label: 'Name',
          hint: 'Name',
        ),
        _buildTextField(
          controller: widget.emailController,
          label: 'Email',
          hint: 'Email Address',
          keyboard: TextInputType.emailAddress,
        ),
        _buildTextField(
          controller: widget.phoneController,
          label: 'Phone Number',
          hint: 'Phone Number',
          keyboard: TextInputType.phone,
        ),
        _buildPasswordField(
          controller: widget.passwordController,
          label: 'Password',
          obscureText: _obscurePassword,
          onToggle: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        _buildPasswordField(
          controller: widget.confirmPasswordController,
          label: 'Confirm Password',
          obscureText: _obscureConfirm,
          onToggle: () {
            setState(() => _obscureConfirm = !_obscureConfirm);
          },
        ),
        const SizedBox(height: kSpacingLarge),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            onPressed: widget.onRegisterPressed,
            child: const Text(
              'Register',
              style: TextStyle(fontSize: 25, color: kWhiteColor),
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: kSpacingSmall / 2),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: kWhiteColor,
            border: kInputBorder,
            enabledBorder: kInputBorder,
            focusedBorder: kInputFocusedBorder,
          ),
        ),
        const SizedBox(height: kSpacingMedium),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: kSpacingSmall / 2),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: label,
            filled: true,
            fillColor: kWhiteColor,
            border: kInputBorder,
            enabledBorder: kInputBorder,
            focusedBorder: kInputFocusedBorder,
            suffixIcon: IconButton(
              icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
              onPressed: onToggle,
            ),
          ),
        ),
        const SizedBox(height: kSpacingMedium),
      ],
    );
  }
}
