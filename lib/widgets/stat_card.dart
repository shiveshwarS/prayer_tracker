import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_palette.dart';
import 'animated_count.dart';

class StatCard extends StatefulWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
  });

  final String label;
  final String value;
  final String caption;
  final IconData icon;

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_reduceMotion) {
      _bounceController.value = 0;
    }
  }

  @override
  void didUpdateWidget(covariant StatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_reduceMotion) {
      _bounceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int? numericValue = int.tryParse(widget.value);
    final Duration quick = AppMotion.resolve(
      context,
      const Duration(milliseconds: 240),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AnimatedBuilder(
                animation: _bounceController,
                builder: (BuildContext context, Widget? child) {
                  final double value = _bounceController.value;
                  final double pulse =
                      value > 0 && value < 1 ? math.sin(value * math.pi) : 0;
                  return Transform.translate(
                    offset: Offset(0, -pulse * 2.5),
                    child: Transform.rotate(angle: pulse * 0.06, child: child),
                  );
                },
                child: Icon(widget.icon, size: 16, color: palette.inkMuted),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: palette.inkMuted,
                    fontSize: 9,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          if (numericValue != null)
            AnimatedCount(
              value: numericValue,
              duration: const Duration(milliseconds: 520),
              style: textTheme.displaySmall?.copyWith(
                height: 0.95,
                letterSpacing: -0.4,
              ),
            )
          else
            AnimatedSwitcher(
              duration: quick,
              child: Text(
                widget.value,
                key: ValueKey<String>(widget.value),
                style: textTheme.displaySmall?.copyWith(
                  height: 0.95,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          const SizedBox(height: 5),
          AnimatedSwitcher(
            duration: quick,
            switchInCurve: AppMotion.enter,
            switchOutCurve: AppMotion.exit,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.18),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              widget.caption,
              key: ValueKey<String>(widget.caption),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(color: palette.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}
