import 'package:flutter/material.dart';
import 'package:prawn__farm/utils/constants.dart';

class SupplierSignupHeader extends StatelessWidget {
  const SupplierSignupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/images/prawncare.jpg',
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 40,
          left: 10,
          child: IconButton(
            iconSize: 50,
            icon: const Icon(
              Icons.arrow_circle_left,
              color: kSecondaryColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}
