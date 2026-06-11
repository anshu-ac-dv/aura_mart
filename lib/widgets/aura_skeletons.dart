import 'package:flutter/material.dart';

class AuraSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const AuraSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<AuraSkeleton> createState() => _AuraSkeletonState();
}

class _AuraSkeletonState extends State<AuraSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.white.withAlpha(13) : Colors.black.withAlpha(13);
    final highlightColor = isDarkMode ? Colors.white.withAlpha(26) : Colors.black.withAlpha(26);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [0.0, 0.5 + (_animation.value / 4), 1.0],
            ),
          ),
        );
      },
    );
  }
}

class ProductSkeleton extends StatelessWidget {
  const ProductSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuraSkeleton(width: double.infinity, height: 180, borderRadius: BorderRadius.all(Radius.circular(25))),
          const SizedBox(height: 15),
          const AuraSkeleton(width: 120, height: 15),
          const SizedBox(height: 8),
          const AuraSkeleton(width: 60, height: 15),
        ],
      ),
    );
  }
}
