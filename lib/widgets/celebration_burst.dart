import 'dart:math' as math;

import 'package:flutter/material.dart';

class CelebrationBurst extends StatelessWidget {
  const CelebrationBurst({
    super.key,
    required this.progress,
    required this.primary,
    required this.secondary,
  });

  final double progress;
  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _BurstPainter(
          progress: progress,
          primary: primary,
          secondary: secondary,
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter({
    required this.progress,
    required this.primary,
    required this.secondary,
  });

  final double progress;
  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) {
      return;
    }
    final Offset center = size.center(Offset.zero);
    final double fade = math.sin(progress * math.pi);

    for (int index = 0; index < 16; index++) {
      final double angle = index * math.pi * 2 / 16 + 0.18;
      final double distance = 24 + (progress * 62);
      final double wobble = math.sin(progress * math.pi * 2 + index) * 5;
      final double lift = progress * (index.isEven ? 18 : 10);
      final Offset point = center.translate(
        math.cos(angle) * (distance + wobble),
        math.sin(angle) * (distance + wobble) - lift,
      );
      final Color color = index.isEven ? primary : secondary;
      final double radius = (index.isEven ? 2.5 : 1.7) * (1 - progress * 0.35);
      canvas.drawCircle(
        point,
        radius,
        Paint()..color = color.withValues(alpha: fade * 0.72),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary;
  }
}
