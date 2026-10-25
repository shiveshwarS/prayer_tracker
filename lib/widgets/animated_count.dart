import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = AppMotion.standard,
    this.textAlign,
  });

  final int value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: AppMotion.resolve(context, duration),
      curve: AppMotion.enter,
      builder: (BuildContext context, double animated, Widget? child) {
        return Text(
          '$prefix${animated.round()}$suffix',
          maxLines: 1,
          textAlign: textAlign,
          style: style,
        );
      },
    );
  }
}
