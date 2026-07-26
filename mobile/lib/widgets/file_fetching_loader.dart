import 'package:flutter/material.dart';

class FileFetchingLoader extends StatefulWidget {
  const FileFetchingLoader({super.key});

  @override
  State<FileFetchingLoader> createState() => _FileFetchingLoaderState();
}

class _FileFetchingLoaderState extends State<FileFetchingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double containerWidth = constraints.maxWidth > 0 ? constraints.maxWidth : 300.0;
        return SizedBox(
          width: containerWidth,
          height: 100,
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(6, (index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // Calculate delay offset: delay = i * 0.6s inside 3s cycle -> i * 0.2 fraction
                  final double delayPercent = index * 0.2;
                  double progress = _controller.value - delayPercent;
                  if (progress < 0.0) {
                    progress += 1.0;
                  }

                  double opacity;
                  double scale;
                  double leftPositionPercent;

                  // keyframes flyRight:
                  // 0% -> left: -10%, scale: 0, opacity: 0
                  // 50% -> left: 45%, scale: 1.2, opacity: 1
                  // 100% -> left: 100%, scale: 0, opacity: 0
                  if (progress <= 0.5) {
                    final double t = progress / 0.5; // normalized 0 to 1
                    opacity = t;
                    scale = t * 1.2;
                    leftPositionPercent = -0.1 + (0.45 - (-0.1)) * Curves.easeInOut.transform(t);
                  } else {
                    final double t = (progress - 0.5) / 0.5; // normalized 0 to 1
                    opacity = 1.0 - t;
                    scale = 1.2 - (1.2 * t);
                    leftPositionPercent = 0.45 + (1.0 - 0.45) * Curves.easeInOut.transform(t);
                  }

                  final double left = leftPositionPercent * containerWidth;

                  return Positioned(
                    left: left - 20, // center adjustment
                    bottom: 25,
                    child: Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: Transform.scale(
                        scale: scale.clamp(0.0, 1.5),
                        child: _buildFileItem(),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildFileItem() {
    return Container(
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF012D1D),
            Color(0xFF0E6C4A),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF012D1D).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // White line 1
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              width: 28,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // White line 2
          Positioned(
            top: 13,
            left: 6,
            child: Container(
              width: 18,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
