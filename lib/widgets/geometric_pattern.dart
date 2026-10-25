import 'dart:math' as math;

import 'package:flutter/material.dart';

class GeometricPattern extends StatelessWidget {
  const GeometricPattern({
    super.key,
    required this.color,
    this.spacing = 46,
    this.opacity = 0.05,
  });

  final Color color;
  final double spacing;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _PatternPainter(
              color: color.withValues(alpha: opacity),
              spacing: spacing,
            ),
          ),
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  const _PatternPainter({required this.color, required this.spacing});

  final Color color;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    final Paint dotPaint = Paint()..color = color.withValues(alpha: 0.75);

    for (double y = spacing / 2; y < size.height + spacing; y += spacing) {
      for (double x = spacing / 2; x < size.width + spacing; x += spacing) {
        final Offset center = Offset(x, y);
        final double radius = spacing * 0.29;
        final Path star = Path();
        for (int index = 0; index < 8; index++) {
          final double angle = index * math.pi / 4;
          final double r = index.isEven ? radius : radius * 0.58;
          final Offset point = center.translate(
            r * math.cos(angle),
            r * math.sin(angle),
          );
          if (index == 0) {
            star.moveTo(point.dx, point.dy);
          } else {
            star.lineTo(point.dx, point.dy);
          }
        }
        star.close();
        canvas.drawPath(star, paint);
        canvas.drawCircle(center, 1.1, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.spacing != spacing;
  }
}
