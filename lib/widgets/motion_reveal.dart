import 'package:flutter/material.dart';

class MotionReveal extends StatelessWidget {
  const MotionReveal({
    super.key,
    required this.animation,
    required this.child,
    this.start = 0,
    this.end = 1,
    this.offset = 10,
    this.curve = Curves.easeOutCubic,
  }) : assert(end > start);

  final Animation<double> animation;
  final Widget child;
  final double start;
  final double end;
  final double offset;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (BuildContext context, Widget? child) {
        final double raw = ((animation.value - start) / (end - start)).clamp(
          0.0,
          1.0,
        );
        final double progress = curve.transform(raw);
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, (1 - progress) * offset),
            child: child,
          ),
        );
      },
    );
  }
}
