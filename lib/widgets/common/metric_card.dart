// lib/widgets/common/metric_card.dart

import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final Color? iconColor;
  final bool useOriginalColors;
  final Color iconBgColor;
  final String value;
  final String label;

  const MetricCard({
    super.key,
    this.icon,
    this.imagePath,
    this.iconColor,
    this.useOriginalColors = true,
    required this.iconBgColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: imagePath != null
              ? Image.asset(
                  imagePath!,
                  color: useOriginalColors ? null : iconColor,
                  width: 40,
                  height: 40,
                )
              : Icon(
                  icon!,
                  color: iconColor,
                  size: 40,
                ),
        ),
        const SizedBox(height: 15),
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

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
              width: 60,
              height: 70,
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
