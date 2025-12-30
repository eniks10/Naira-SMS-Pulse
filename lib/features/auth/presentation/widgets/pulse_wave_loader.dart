import 'package:flutter/material.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';

class PulseWaveLoader extends StatefulWidget {
  const PulseWaveLoader({super.key, this.size = 50.0, this.color});

  final double size;
  final Color? color;

  @override
  State<PulseWaveLoader> createState() => _PulseWaveLoaderState();
}

class _PulseWaveLoaderState extends State<PulseWaveLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Speed of the wave
    )..repeat(); // Loop forever
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine dot size based on container size
    final double dotSize = widget.size * 0.18;

    return SizedBox(
      width: widget.size,
      height: dotSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(4, (index) {
          // Calculate delay for each dot
          // Dot 0: 0.0 - 0.5
          // Dot 1: 0.2 - 0.7
          // Dot 2: 0.4 - 0.9
          // Dot 3: 0.6 - 1.0
          final begin = index * 0.2;
          final end = begin + 0.5;

          return _AnimatedDot(
            controller: _controller,
            color: widget.color ?? AppColors.secondaryColor,
            size: dotSize,
            interval: Interval(
              begin.clamp(0.0, 1.0),
              end.clamp(0.0, 1.0),
              curve: Curves.easeInOut,
            ),
          );
        }),
      ),
    );
  }
}

class _AnimatedDot extends StatelessWidget {
  const _AnimatedDot({
    required this.controller,
    required this.color,
    required this.size,
    required this.interval,
  });

  final AnimationController controller;
  final Color color;
  final double size;
  final Interval interval;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Evaluate the specific interval for this dot
        // This returns 0.0 -> 1.0 -> 0.0
        final double value = interval.transform(controller.value);

        // Use a Sine wave to make it grow and shrink smoothly
        // If value is 0.5 (peak of interval), scale is max.
        final double scale = 1.0 - (0.5 * (1.0 - (2 * (0.5 - value).abs())));

        // Or simpler: Just map 0->1 to Scale 0.5->1.0
        // Let's use a simpler Transform for clarity:
        // We want the dot to jump up (scale up) then down.

        final double scaleValue = 0.6 + (0.4 * value); // Min size 60%, Max 100%
        final double opacityValue =
            0.5 + (0.5 * value); // Min fade 50%, Max 100%

        return Transform.scale(
          scale: scaleValue,
          child: Opacity(
            opacity: opacityValue,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        );
      },
    );
  }
}
