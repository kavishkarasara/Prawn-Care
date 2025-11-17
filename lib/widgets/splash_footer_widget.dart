import 'package:flutter/material.dart';

class SplashFooterWidget extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const SplashFooterWidget({
    Key? key,
    required this.fadeAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - fadeAnimation.value)),
          child: Opacity(
            opacity: fadeAnimation.value,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: screenHeight * 0.05,
                left: screenWidth * 0.05,
                right: screenWidth * 0.05,
              ),
              child: Image.asset(
                'assets/images/prawncare.jpg',
                height: _getResponsiveFooterSize(screenWidth, isTablet) * 2,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  double _getResponsiveFooterSize(double screenWidth, bool isTablet) {
    if (isTablet) {
      return screenWidth * 0.025;
    } else {
      return screenWidth * 0.035;
    }
  }
}
