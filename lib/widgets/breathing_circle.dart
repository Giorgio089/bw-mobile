import 'dart:math';
import 'package:flutter/material.dart';
import '../models/breathing_technique.dart';

/// Animated circular breathwork visualisation.
///
/// Expands on inhale, shrinks on exhale, holds steady otherwise.
class BreathingCircle extends StatefulWidget {
  final BreathingPhase phase;
  final Duration phaseDuration;
  final bool isRunning;
  final Color color;
  final int secondsRemaining;

  const BreathingCircle({
    super.key,
    required this.phase,
    required this.phaseDuration,
    required this.isRunning,
    required this.color,
    required this.secondsRemaining,
  });

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.phaseDuration,
    );

    if (widget.isRunning) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(BreathingCircle oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If phase changed, reset and start new animation
    if (widget.phase != oldWidget.phase || widget.phaseDuration != oldWidget.phaseDuration) {
      _controller.duration = widget.phaseDuration;
      _controller.reset();
      if (widget.isRunning) {
        _controller.forward();
      }
    } else if (widget.isRunning != oldWidget.isRunning) {
      // If running state changed, pause or resume
      if (widget.isRunning) {
        _controller.forward();
      } else {
        _controller.stop();
      }
    }
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
        // Use 80% of available space but max 400px
        final size = min(constraints.maxWidth * 0.8, 400.0);

        return Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = _controller.value;
              
              // Scale range: 0.5 (small) to 1.0 (full)
              double scale;
              switch (widget.phase) {
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

              return SizedBox(
                width: size,
                height: size,
                child: Transform.scale(
                  scale: scale,
                  child: CustomPaint(
                    painter: _CirclePainter(
                      color: widget.color,
                      progress: progress,
                      phase: widget.phase,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.secondsRemaining.toString(),
                            style: TextStyle(
                              fontSize: size * 0.25,
                              fontWeight: FontWeight.w300,
                              color: widget.color.withAlpha(230),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _phaseLabel(widget.phase),
                            style: TextStyle(
                              fontSize: size * 0.05,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2,
                              color: widget.color.withAlpha(200),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
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
