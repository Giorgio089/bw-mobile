import 'dart:math';
import 'package:flutter/material.dart';
import '../models/breathing_technique.dart';

/// Animated circular breathwork visualisation.
///
/// Expands on inhale, shrinks on exhale, holds steady otherwise.
class BreathingCircle extends StatelessWidget {
  final BreathingPhase phase;
  final double progress; // 0.0 – 1.0 within current phase
  final Color color;
  final int secondsRemaining;

  const BreathingCircle({
    super.key,
    required this.phase,
    required this.progress,
    required this.color,
    required this.secondsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    // Scale range: 0.5 (small) to 1.0 (full)
    double scale;
    switch (phase) {
      case BreathingPhase.inhale:
        scale = 0.5 + 0.5 * Curves.easeInOut.transform(progress);
        break;
      case BreathingPhase.exhale:
        scale = 1.0 - 0.5 * Curves.easeInOut.transform(progress);
        break;
      case BreathingPhase.hold:
        scale = 1.0;
        break;
      case BreathingPhase.holdAfterExhale:
        scale = 0.5;
        break;
    }

    final size = MediaQuery.of(context).size.width * 0.6;

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 80),
        curve: Curves.linear,
        child: CustomPaint(
          painter: _CirclePainter(
            color: color,
            progress: progress,
            phase: phase,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  secondsRemaining.toString(),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color: color.withAlpha(230),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _phaseLabel(phase),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                    color: color.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _phaseLabel(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
        return 'EINATMEN';
      case BreathingPhase.hold:
        return 'HALTEN';
      case BreathingPhase.exhale:
        return 'AUSATMEN';
      case BreathingPhase.holdAfterExhale:
        return 'HALTEN';
    }
  }
}

class _CirclePainter extends CustomPainter {
  final Color color;
  final double progress;
  final BreathingPhase phase;

  _CirclePainter({
    required this.color,
    required this.progress,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer glow
    final glowPaint = Paint()
      ..color = color.withAlpha(30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(center, radius, glowPaint);

    // Main circle with gradient
    final gradient = RadialGradient(
      colors: [
        color.withAlpha(100),
        color.withAlpha(50),
        color.withAlpha(20),
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    final circlePaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawCircle(center, radius, circlePaint);

    // Border ring
    final borderPaint = Paint()
      ..color = color.withAlpha(120)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, borderPaint);

    // Progress arc
    final arcPaint = Paint()
      ..color = color.withAlpha(200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.phase != phase;
  }
}
