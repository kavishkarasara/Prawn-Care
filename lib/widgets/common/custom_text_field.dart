import 'package:flutter/material.dart';
import 'package:prawn__farm/utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: kWhiteColor,
        border: kInputBorder,
        enabledBorder: kInputBorder,
        focusedBorder: kInputFocusedBorder,
        errorBorder: kInputErrorBorder,
        focusedErrorBorder: kInputErrorBorder,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
