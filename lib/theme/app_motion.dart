import 'package:flutter/material.dart';

abstract final class AppMotion {
  static const Duration quick = Duration(milliseconds: 180);
  static const Duration standard = Duration(milliseconds: 280);
  static const Duration emphasized = Duration(milliseconds: 520);
  static const Duration entrance = Duration(milliseconds: 850);
  static const Duration celebration = Duration(milliseconds: 1900);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve spring = Curves.easeOutBack;
  static const Curve exit = Curves.easeInCubic;

  static bool enabled(BuildContext context) {
    return !MediaQuery.of(context).disableAnimations;
  }

  static Duration resolve(BuildContext context, Duration duration) {
    return enabled(context) ? duration : Duration.zero;
  }
}
