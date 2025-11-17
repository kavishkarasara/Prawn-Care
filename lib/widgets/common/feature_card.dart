// lib/widgets/common/feature_card.dart

import 'package:flutter/material.dart';

class FeatureCard extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final Color? iconColor;
  final bool useOriginalColors;
  final Color iconBgColor;
  final String title;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    this.icon,
    this.imagePath,
    this.iconColor,
    this.useOriginalColors = false,
    required this.iconBgColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color.fromARGB(255, 200, 198, 198),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 500,
              height: 100,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: imagePath != null
                  ? Image.asset(
                      imagePath!,
                      color: useOriginalColors ? null : iconColor,
                      width: 60,
                      height: 60,
                    )
                  : Icon(
                      icon!,
                      color: iconColor,
                      size: 50,
                    ),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
