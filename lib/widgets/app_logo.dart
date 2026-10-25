import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Semantics(
      label: 'Noor crescent logo',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: _NoorMarkPainter(
          background: palette.inverse,
          foreground: palette.inverseInk,
        ),
      ),
    );
  }
}

class _NoorMarkPainter extends CustomPainter {
  const _NoorMarkPainter({required this.background, required this.foreground});

  final Color background;
  final Color foreground;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect backgroundRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.width * 0.29),
    );
    canvas.drawRRect(backgroundRect, Paint()..color = background);

    final double unit = size.width / 100;
    final Offset center = Offset(50 * unit, 53 * unit);
    final Path outerMoon =
        Path()..addOval(Rect.fromCircle(center: center, radius: 24 * unit));
    final Path cutout =
        Path()..addOval(
          Rect.fromCircle(
            center: center.translate(10 * unit, -7 * unit),
            radius: 21 * unit,
          ),
        );
    final Path moon = Path.combine(PathOperation.difference, outerMoon, cutout);
    canvas.drawPath(moon, Paint()..color = foreground);

    final Offset starCenter = Offset(69 * unit, 31 * unit);
    final double outer = 7 * unit;
    final double inner = 2.1 * unit;
    final Path star = Path();
    for (int index = 0; index < 8; index++) {
      final double angle = (-90 + index * 45) * math.pi / 180;
      final double radius = index.isEven ? outer : inner;
      final Offset point = starCenter.translate(
        radius * math.cos(angle),
        radius * math.sin(angle),
      );
      if (index == 0) {
        star.moveTo(point.dx, point.dy);
      } else {
        star.lineTo(point.dx, point.dy);
      }
    }
    star.close();
    canvas.drawPath(star, Paint()..color = foreground);
  }

  @override
  bool shouldRepaint(covariant _NoorMarkPainter oldDelegate) {
    return oldDelegate.background != background ||
        oldDelegate.foreground != foreground;
  }
}
