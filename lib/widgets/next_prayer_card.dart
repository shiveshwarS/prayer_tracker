import 'package:flutter/material.dart';

import '../models/prayer.dart';
import '../models/prayer_times.dart';
import '../theme/app_motion.dart';
import '../theme/app_palette.dart';
import '../utils/date_utils.dart';
import 'geometric_pattern.dart';

class NextPrayerCard extends StatelessWidget {
  const NextPrayerCard({
    super.key,
    required this.nextPrayer,
    required this.locationLabel,
    required this.onEditLocation,
    this.previousTime,
    this.now,
  });

  final NextPrayerInfo nextPrayer;
  final String locationLabel;
  final VoidCallback onEditLocation;
  final DateTime? previousTime;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DateTime current = now ?? DateTime.now();
    final String dayLabel = nextPrayer.isTomorrow ? 'Tomorrow' : 'Today';
    final String countdown = _formatRemaining(nextPrayer.time.difference(current));
    final double progress = _progress(current);
    final Duration motion = AppMotion.resolve(context, AppMotion.standard);
    final Duration heroMotion = AppMotion.resolve(context, AppMotion.hero);

    return Semantics(
      container: true,
      label:
          'Next prayer is ${nextPrayer.prayer.label} at '
          '${AppDate.formatTime(nextPrayer.time)}, '
          '${countdown == 'Now' ? 'now' : 'in $countdown'}. '
          '$locationLabel.',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: palette.shadow,
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        palette.inverse,
                        Color.lerp(palette.inverse, palette.inverseInk, 0.08)!,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: GeometricPattern(
                  color: palette.inverseInk,
                  opacity: 0.055,
                  spacing: 44,
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(1.05, -0.9),
                        radius: 1.05,
                        colors: <Color>[
                          palette.gold.withValues(alpha: 0.2),
                          palette.gold.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: palette.inverseInk.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _iconFor(nextPrayer.prayer),
                            color: palette.inverseInk,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'NEXT PRAYER · ${dayLabel.toUpperCase()}',
                                style: textTheme.labelSmall?.copyWith(
                                  color: palette.inverseInk.withValues(
                                    alpha: 0.52,
                                  ),
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: <Widget>[
                                  Flexible(
                                    child: Text(
                                      nextPrayer.prayer.label,
                                      style: textTheme.titleLarge?.copyWith(
                                        color: palette.inverseInk,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    nextPrayer.prayer.translation,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: palette.inverseInk.withValues(
                                        alpha: 0.58,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: onEditLocation,
                          tooltip: 'Change prayer location',
                          style: IconButton.styleFrom(
                            foregroundColor: palette.inverseInk,
                          ),
                          icon: const Icon(Icons.tune_rounded, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'TIME REMAINING',
                      style: textTheme.labelSmall?.copyWith(
                        color: palette.inverseInk.withValues(alpha: 0.46),
                        fontSize: 9,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedSwitcher(
                      duration: motion,
                      switchInCurve: AppMotion.enter,
                      switchOutCurve: AppMotion.exit,
                      alignment: Alignment.centerLeft,
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                      ) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.12),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        countdown,
                        key: ValueKey<String>('countdown-$countdown'),
                        style: textTheme.displayMedium?.copyWith(
                          color: palette.inverseInk,
                          fontSize: 48,
                          height: 0.98,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      countdown == 'Now'
                          ? 'The adhan is due now'
                          : 'at ${AppDate.formatTime(nextPrayer.time)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: palette.inverseInk.withValues(alpha: 0.62),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 5,
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            ColoredBox(
                              color: palette.inverseInk.withValues(alpha: 0.14),
                            ),
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: progress),
                              duration: heroMotion,
                              curve: AppMotion.enter,
                              builder: (
                                BuildContext context,
                                double value,
                                Widget? child,
                              ) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: value.clamp(0, 1),
                                    heightFactor: 1,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: palette.gold,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: palette.inverseInk.withValues(alpha: 0.55),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            locationLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: palette.inverseInk.withValues(alpha: 0.58),
                              fontSize: 11,
                            ),
                          ),
                        ),
                        if (previousTime != null) ...<Widget>[
                          const SizedBox(width: 8),
                          Text(
                            'since ${AppDate.formatTime(previousTime!)}',
                            style: textTheme.labelSmall?.copyWith(
                              color: palette.inverseInk.withValues(alpha: 0.46),
                              fontSize: 8.5,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRemaining(Duration remaining) {
    if (remaining <= Duration.zero) {
      return 'Now';
    }
    final int totalMinutes = (remaining.inSeconds / 60).ceil();
    if (totalMinutes <= 0) {
      return 'Now';
    }
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    if (hours == 0) {
      return '${minutes}m';
    }
    if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes}m';
  }

  double _progress(DateTime current) {
    final DateTime? previous = previousTime;
    if (previous == null) {
      return 0;
    }
    final int total = nextPrayer.time.difference(previous).inSeconds;
    if (total <= 0) {
      return 0;
    }
    return (current.difference(previous).inSeconds / total).clamp(0, 1);
  }

  IconData _iconFor(PrayerId prayer) {
    switch (prayer) {
      case PrayerId.fajr:
        return Icons.brightness_5_outlined;
      case PrayerId.dhuhr:
        return Icons.wb_sunny_outlined;
      case PrayerId.asr:
        return Icons.light_mode_outlined;
      case PrayerId.maghrib:
        return Icons.wb_twilight;
      case PrayerId.isha:
        return Icons.dark_mode_outlined;
    }
  }
}
