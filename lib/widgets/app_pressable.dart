import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_motion.dart';

/// Animates a child while it is being pressed without competing for gestures.
///
/// Use this around Material buttons that already handle their own taps.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.pressedScale = 0.965,
    this.duration = const Duration(milliseconds: 120),
  });

  final Widget child;
  final bool enabled;
  final double pressedScale;
  final Duration duration;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) {
      return;
    }
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: AppMotion.resolve(context, widget.duration),
        curve: AppMotion.springSoft,
        child: widget.child,
      ),
    );
  }
}

/// A tappable surface with a spring press response, ripple and semantics.
class AppPressable extends StatelessWidget {
  const AppPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.semanticLabel,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.pressedScale = 0.975,
    this.enabled = true,
    this.haptic = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final BorderRadius borderRadius;
  final double pressedScale;
  final bool enabled;
  final bool haptic;

  bool get _canTap => enabled && onTap != null;

  void _handleTap() {
    if (!_canTap) {
      return;
    }
    if (haptic) {
      HapticFeedback.selectionClick();
    }
    onTap!.call();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: _canTap,
      label: semanticLabel,
      child: PressScale(
        enabled: _canTap,
        pressedScale: pressedScale,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: _canTap ? _handleTap : null,
            borderRadius: borderRadius,
            child: child,
          ),
        ),
      ),
    );
  }
}
