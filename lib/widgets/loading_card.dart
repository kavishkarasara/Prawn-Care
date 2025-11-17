import 'package:flutter/material.dart';

class LoadingCard extends StatelessWidget {
  final Animation<double> shimmerAnimation;

  const LoadingCard({
    super.key,
    required this.shimmerAnimation,
  });

  Widget _buildShimmerContainer(
      double width, double height, double borderRadius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[300]!,
                    Colors.grey[100]!,
                    Colors.grey[300]!,
                  ],
                  stops: [
                    shimmerAnimation.value - 1,
                    shimmerAnimation.value,
                    shimmerAnimation.value + 1,
                  ],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildShimmerContainer(40, 40, 8),
          const SizedBox(height: 12),
          _buildShimmerContainer(80, 20, 4),
          const SizedBox(height: 8),
          _buildShimmerContainer(60, 14, 4),
          const SizedBox(height: 6),
          _buildShimmerContainer(50, 20, 12),
        ],
      ),
    );
  }
}
