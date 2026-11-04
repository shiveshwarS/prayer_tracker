import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A small, deterministic particle burst. Wrap it in a [RepaintBoundary] and
/// drive [progress] from 0 to 1 with a finite controller.
class SparkleBurst extends StatelessWidget {
  const SparkleBurst({
    super.key,
    required this.progress,
    required this.primary,
    this.secondary,
    this.count = 12,
    this.radius = 38,
    this.dotSize = 2.2,
    this.spread = 1,
  });

  final double progress;
  final Color primary;
  final Color? secondary;
  final int count;
  final double radius;
  final double dotSize;
  final double spread;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: CustomPaint(
          painter: _SparkleBurstPainter(
            progress: progress,
            primary: primary,
            secondary: secondary ?? primary,
            count: count,
            radius: radius,
            dotSize: dotSize,
            spread: spread,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _SparkleBurstPainter extends CustomPainter {
  const _SparkleBurstPainter({
    required this.progress,
    required this.primary,
    required this.secondary,
    required this.count,
    required this.radius,
    required this.dotSize,
    required this.spread,
  });

  final double progress;
  final Color primary;
  final Color secondary;
  final int count;
  final double radius;
  final double dotSize;
  final double spread;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1 || size.isEmpty) {
      return;
    }
    final Offset center = size.center(Offset.zero);
    final double eased = Curves.easeOutCubic.transform(progress);
    final double fade = math.sin(progress * math.pi);
    for (int index = 0; index < count; index++) {
      final double angle = index * math.pi * 2 / count + 0.22;
      final double wobble =
          math.sin(progress * math.pi * 2 + index * 1.7) * 3.5;
      final double distance = (radius * eased + wobble) * spread;
      final Offset point = center.translate(
        math.cos(angle) * distance,
        math.sin(angle) * distance - eased * 9,
      );
      final Color color = index.isEven ? primary : secondary;
      final double sizeFactor = index % 3 == 0 ? 1.25 : 0.85;
      canvas.drawCircle(
        point,
        dotSize * sizeFactor * (1 - progress * 0.3),
        Paint()..color = color.withValues(alpha: fade * 0.78),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparkleBurstPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.count != count ||
        oldDelegate.radius != radius ||
        oldDelegate.dotSize != dotSize ||
        oldDelegate.spread != spread;
  }
}
