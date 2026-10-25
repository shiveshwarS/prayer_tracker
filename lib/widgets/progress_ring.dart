import 'dart:math' as math;

import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.completed,
    required this.total,
    required this.progressColor,
    required this.trackColor,
    required this.textColor,
    this.size = 92,
  });

  final int completed;
  final int total;
  final Color progressColor;
  final Color trackColor;
  final Color textColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final double progress = total == 0 ? 0 : completed / total;
    return Semantics(
      label: '$completed of $total prayers completed',
      value: '${(progress * 100).round()} percent',
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (BuildContext context, double value, Widget? child) {
                return CustomPaint(
                  painter: _RingPainter(
                    progress: value,
                    trackColor: trackColor,
                    progressColor: progressColor,
                  ),
                );
              },
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '$completed/$total',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    'PRAYERS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: textColor.withValues(alpha: 0.62),
                      fontSize: 8,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double stroke = size.width * 0.083;
    final Rect rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (size.width - stroke) / 2,
    );
    final Paint track =
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round;
    final Paint fill =
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress.clamp(0, 1),
        false,
        fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
