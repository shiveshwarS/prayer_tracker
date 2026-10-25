import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/prayer_moment.dart';
import '../theme/app_motion.dart';
import '../theme/app_palette.dart';
import '../utils/date_utils.dart';
import 'celebration_burst.dart';

class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({
    super.key,
    required this.moment,
    required this.onDismissed,
  });

  final PrayerMoment moment;
  final VoidCallback onDismissed;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _dismissTimer;
  bool _started = false;
  bool _reduceMotion = false;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.celebration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
    _dismissTimer = Timer(const Duration(milliseconds: 1850), _dismiss);
  }

  void _dismiss() {
    if (_dismissed) {
      return;
    }
    _dismissed = true;
    widget.onDismissed();
  }

  String get _title {
    final int? milestone = widget.moment.milestone;
    if (milestone == 1) {
      return 'Your first complete day';
    }
    if (milestone != null) {
      return '$milestone days of prayer';
    }
    return 'A full day of prayer';
  }

  String get _message {
    if (widget.moment.newPersonalBest) {
      if (widget.moment.currentStreak <= 1) {
        return 'Every prayer is complete. A new beginning.';
      }
      return 'Every prayer is complete. A new personal best of '
          '${widget.moment.currentStreak} days.';
    }
    if (widget.moment.currentStreak > 1) {
      return 'Every prayer is complete. '
          '${widget.moment.currentStreak} days in a row.';
    }
    return 'MashaAllah. Every prayer is complete today.';
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double value = _controller.value;
        final double opacity =
            _reduceMotion
                ? 1
                : math.min(
                  (value / 0.14).clamp(0.0, 1.0),
                  ((1 - value) / 0.2).clamp(0.0, 1.0),
                );
        final double scale =
            _reduceMotion
                ? 1
                : 0.94 +
                    Curves.easeOutBack.transform(
                          (value / 0.22).clamp(0.0, 1.0),
                        ) *
                        0.06;
        final double burst =
            _reduceMotion ? 0 : ((value - 0.08) / 0.55).clamp(0.0, 1.0);

        return SafeArea(
          child: Align(
            alignment: const Alignment(0, -0.13),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: SizedBox(
                    width: 360,
                    height: 250,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        Positioned.fill(
                          child: RepaintBoundary(
                            child: CelebrationBurst(
                              progress: burst,
                              primary: palette.ink,
                              secondary: palette.inkMuted,
                            ),
                          ),
                        ),
                        Semantics(
                          liveRegion: true,
                          container: true,
                          label: '$_title. $_message',
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                            decoration: BoxDecoration(
                              color: palette.inverse,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: palette.inverseInk.withValues(
                                  alpha: 0.12,
                                ),
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: palette.shadow,
                                  blurRadius: 30,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: palette.inverseInk.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Icon(
                                        Icons.check_rounded,
                                        size: 20,
                                        color: palette.inverseInk,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'A MOMENT OF PRAYER',
                                            style: textTheme.labelSmall
                                                ?.copyWith(
                                                  color: palette.inverseInk
                                                      .withValues(alpha: 0.55),
                                                  fontSize: 8.5,
                                                  letterSpacing: 1.2,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _title,
                                            style: textTheme.headlineSmall
                                                ?.copyWith(
                                                  color: palette.inverseInk,
                                                  fontWeight: FontWeight.w800,
                                                  height: 1.05,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _message,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: palette.inverseInk.withValues(
                                      alpha: 0.66,
                                    ),
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 11),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: palette.inverseInk.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(
                                        Icons.local_fire_department_outlined,
                                        size: 13,
                                        color: palette.inverseInk,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        AppDate.formatDays(
                                          widget.moment.currentStreak,
                                        ),
                                        style: textTheme.labelSmall?.copyWith(
                                          color: palette.inverseInk,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
