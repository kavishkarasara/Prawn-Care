import 'package:flutter/material.dart';
import 'package:prawn__farm/utils/constants.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: kWhiteColor,
                  strokeWidth: 3,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  color: kWhiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
