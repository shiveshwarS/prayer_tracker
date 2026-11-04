import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_palette.dart';

/// A very low-contrast animated background: slow colour orbs, a soft vignette
/// and a few drifting geometric motifs.
///
/// The painter is intentionally cheap and is always isolated in a
/// [RepaintBoundary]. When the app requests reduced motion the controller stops
/// and the composition settles into a still, balanced frame.
class LivingBackground extends StatefulWidget {
  const LivingBackground({
    super.key,
    this.scrollController,
    this.intensity = 1,
    this.showMotifs = true,
  });

  final ScrollController? scrollController;
  final double intensity;
  final bool showMotifs;

  @override
  State<LivingBackground> createState() => _LivingBackgroundState();
}

class _LivingBackgroundState extends State<LivingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.ambient);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool enabled = AppMotion.enabled(context);
    if (enabled) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller
        ..stop()
        ..value = 0.32;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final ScrollController? scroll = widget.scrollController;
    final Listenable animation =
        scroll == null
            ? _controller
            : Listenable.merge(<Listenable>[_controller, scroll]);

    return IgnorePointer(
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              final double scrollOffset =
                  scroll != null && scroll.hasClients ? scroll.offset : 0;
              return CustomPaint(
                painter: _LivingBackgroundPainter(
                  phase: _controller.value,
                  scrollOffset: scrollOffset,
                  intensity: widget.intensity,
                  haloCool: palette.haloCool,
                  haloWarm: palette.haloWarm,
                  gold: palette.gold,
                  showMotifs: widget.showMotifs,
                ),
                size: Size.infinite,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LivingBackgroundPainter extends CustomPainter {
  const _LivingBackgroundPainter({
    required this.phase,
    required this.scrollOffset,
    required this.intensity,
    required this.haloCool,
    required this.haloWarm,
    required this.gold,
    required this.showMotifs,
  });

  final double phase;
  final double scrollOffset;
  final double intensity;
  final Color haloCool;
  final Color haloWarm;
  final Color gold;
  final bool showMotifs;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    final double p = phase * math.pi * 2;
    final double parallax = scrollOffset.clamp(0, 900) * 0.075;

    _drawOrb(
      canvas,
      size,
      center: Offset(
        size.width * (0.18 + 0.035 * math.sin(p)),
        size.height * (0.11 + 0.025 * math.cos(p * 0.8)) - parallax,
      ),
      radius: size.shortestSide * 0.62,
      color: haloCool,
      opacity: 0.075 * intensity,
    );

    _drawOrb(
      canvas,
      size,
      center: Offset(
        size.width * (0.88 + 0.03 * math.cos(p * 0.7)),
        size.height * (0.58 + 0.035 * math.sin(p * 0.9)) + parallax * 0.6,
      ),
      radius: size.shortestSide * 0.72,
      color: haloWarm,
      opacity: 0.055 * intensity,
    );

    _drawOrb(
      canvas,
      size,
      center: Offset(
        size.width * (0.58 + 0.05 * math.sin(p * 0.55 + 1.2)),
        size.height * (0.92 + 0.02 * math.cos(p * 0.6)),
      ),
      radius: size.shortestSide * 0.48,
      color: gold,
      opacity: 0.035 * intensity,
    );

    if (!showMotifs) {
      return;
    }

    final Paint motifPaint =
        Paint()
          ..color = gold.withValues(alpha: 0.075 * intensity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9;
    final Offset drift = Offset(0, -parallax * 0.35);
    for (int index = 0; index < 7; index++) {
      final double seed = index * 1.73;
      final double x =
          size.width * (0.1 + 0.8 * _fract(seed * 0.37 + 0.13));
      final double baseY =
          size.height * (0.08 + 0.84 * _fract(seed * 0.61 + 0.07));
      final double y =
          baseY + math.sin(p * 0.5 + seed) * 9 + drift.dy;
      final double radius = 5.5 + (index % 3) * 2.4;
      _drawStar(
        canvas,
        Offset(x, y),
        radius * (1 + 0.06 * math.sin(p + seed)),
        motifPaint,
      );
    }
  }

  double _fract(double value) => value - value.floorToDouble();

  void _drawOrb(
    Canvas canvas,
    Size size, {
    required Offset center,
    required double radius,
    required Color color,
    required double opacity,
  }) {
    if (opacity <= 0) {
      return;
    }
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final Paint paint =
        Paint()
          ..shader = RadialGradient(
            colors: <Color>[
              color.withValues(alpha: opacity),
              color.withValues(alpha: opacity * 0.35),
              color.withValues(alpha: 0),
            ],
            stops: const <double>[0, 0.52, 1],
          ).createShader(rect);
    canvas.drawCircle(center, radius, paint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final Path star = Path();
    for (int index = 0; index < 8; index++) {
      final double angle = (-90 + index * 45) * math.pi / 180;
      final double r = index.isEven ? radius : radius * 0.42;
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
  }

  @override
  bool shouldRepaint(covariant _LivingBackgroundPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.intensity != intensity ||
        oldDelegate.haloCool != haloCool ||
        oldDelegate.haloWarm != haloWarm ||
        oldDelegate.gold != gold ||
        oldDelegate.showMotifs != showMotifs;
  }
}
