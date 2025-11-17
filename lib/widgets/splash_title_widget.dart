import 'package:flutter/material.dart';

class SplashTitleWidget extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;

  const SplashTitleWidget({
    Key? key,
    required this.fadeAnimation,
    required this.scaleAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final titleSize =
        _getResponsiveTitleSize(screenWidth, isTablet, isLandscape);
    final strokeWidth = _getStrokeWidth(screenWidth);

    return AnimatedBuilder(
      animation: Listenable.merge([fadeAnimation, scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: Opacity(
            opacity: fadeAnimation.value,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Stack(
                  children: [
                    // Stroke text
                    Text(
                      '',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = strokeWidth
                          ..color = Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // Fill text
                    Text(
                      '',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _getResponsiveTitleSize(
      double screenWidth, bool isTablet, bool isLandscape) {
    if (isTablet) {
      return isLandscape ? screenWidth * 0.10 : screenWidth * 0.12;
    } else if (screenWidth < 360) {
      // Small mobile screens
      return isLandscape ? screenWidth * 0.15 : screenWidth * 0.18;
    } else if (screenWidth < 400) {
      // Medium mobile screens
      return isLandscape ? screenWidth * 0.12 : screenWidth * 0.15;
    } else {
      // Large mobile screens (400-600px)
      return isLandscape ? screenWidth * 0.10 : screenWidth * 0.12;
    }
  }

  double _getStrokeWidth(double screenWidth) {
    if (screenWidth > 600) {
      return 4.0;
    } else if (screenWidth > 400) {
      return 3.0;
    } else {
      return 2.5;
    }
  }
}
