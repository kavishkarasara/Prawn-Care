import 'package:flutter/material.dart';

class SupplierSigninHeader extends StatelessWidget {
  const SupplierSigninHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/images/prawncare.jpg',
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 40,
          left: 10,
          child: IconButton(
            iconSize: 50,
            icon: const Icon(
              Icons.arrow_circle_left,
              color: Color.fromARGB(255, 184, 184, 184),
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
