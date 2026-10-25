import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import 'animated_count.dart';

class ProgressRing extends StatefulWidget {
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
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _celebrationController;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_reduceMotion) {
      _celebrationController.value = 0;
    }
  }

  @override
  void didUpdateWidget(covariant ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool wasComplete =
        oldWidget.total > 0 && oldWidget.completed >= oldWidget.total;
    final bool isComplete =
        widget.total > 0 && widget.completed >= widget.total;
    if (!wasComplete && isComplete && !_reduceMotion) {
      _celebrationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress =
        widget.total == 0 ? 0 : widget.completed / widget.total;

    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (BuildContext context, Widget? child) {
        final double value = _celebrationController.value;
        final double pulse =
            value > 0 && value < 1 ? math.sin(value * math.pi) : 0;

        return Transform.scale(
          scale: 1 + pulse * 0.035,
          child: Semantics(
            label: '${widget.completed} of ${widget.total} prayers completed',
            value: '${(progress * 100).round()} percent',
            child: SizedBox.square(
              dimension: widget.size,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progress),
                    duration: AppMotion.resolve(
                      context,
                      const Duration(milliseconds: 650),
                    ),
                    curve: AppMotion.enter,
                    builder: (
                      BuildContext context,
                      double animated,
                      Widget? child,
                    ) {
                      return RepaintBoundary(
                        child: CustomPaint(
                          painter: _RingPainter(
                            progress: animated,
                            trackColor: widget.trackColor,
                            progressColor: widget.progressColor,
                            glow: pulse,
                          ),
                        ),
                      );
                    },
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: <Widget>[
                            AnimatedCount(
                              value: widget.completed,
                              duration: const Duration(milliseconds: 520),
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                color: widget.textColor,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            Text(
                              '/${widget.total}',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                color: widget.textColor,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'PRAYERS',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: widget.textColor.withValues(alpha: 0.62),
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
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.glow,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double glow;

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

    if (progress >= 1) {
      final Paint halo =
          Paint()
            ..color = progressColor.withValues(alpha: 0.1 + glow * 0.12)
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke * 2.2
            ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, 0, math.pi * 2, false, halo);
    }

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
        oldDelegate.progressColor != progressColor ||
        oldDelegate.glow != glow;
  }
}
