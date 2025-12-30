import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';

class AnimatedPulsePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  AnimatedPulsePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Define the brush (Sleek, White, rounded caps)
    final paint = Paint()
      ..color = AppColors.secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 2. Define the path (The Shape)
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(0, h * 0.7);
    path.lineTo(w * 0.2, h * 0.7); // Flat start
    path.lineTo(w * 0.3, h * 0.35); // Heartbeat Up
    path.lineTo(w * 0.4, h * 0.85); // Heartbeat Down
    path.lineTo(w * 0.5, h * 0.65); // Back to mid
    path.lineTo(w * 0.6, h * 0.65); // Small flat
    path.lineTo(w * 0.7, h * 0.2); // Big Growth Spike Up!
    path.lineTo(w * 0.8, h * 0.2); // Top plateau
    path.lineTo(w * 0.85, h * 0.15); // Arrow tip part 1
    path.moveTo(w * 0.8, h * 0.2);
    path.lineTo(w * 0.8, h * 0.28); // Arrow tip part 2

    // 3. The Magic: Extract only the part of the path based on progress
    // We use PathMetrics to measure the line and cut it.
    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      Path extractPath = pathMetric.extractPath(
        0.0,
        pathMetric.length * progress, // Draw from 0% to current %
      );
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedPulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
