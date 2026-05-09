import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.1),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }

  static Widget card({double height = 160}) {
    return SkeletonLoader(width: double.infinity, height: height, borderRadius: BorderRadius.circular(24));
  }

  static Widget listTile() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const SkeletonLoader(width: 50, height: 50, borderRadius: BorderRadius.all(Radius.circular(25))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoader(width: 150, height: 16),
                const SizedBox(height: 8),
                const SkeletonLoader(width: 100, height: 12),
              ],
            ),
          ),
          const SkeletonLoader(width: 60, height: 20),
        ],
      ),
    );
  }
}
