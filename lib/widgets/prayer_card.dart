import 'package:flutter/material.dart';

import '../models/prayer.dart';
import '../theme/app_palette.dart';
import '../utils/date_utils.dart';

class PrayerCard extends StatelessWidget {
  const PrayerCard({
    super.key,
    required this.prayer,
    required this.time,
    required this.completed,
    required this.onToggle,
  });

  final PrayerId prayer;
  final DateTime? time;
  final bool completed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color foreground = completed ? palette.inverseInk : palette.ink;
    final Color muted = completed ? palette.inverseMuted : palette.inkMuted;
    final String status = completed ? 'Completed' : 'Not completed';
    final String timeLabel =
        time == null ? 'Prayer times unavailable' : AppDate.formatTime(time!);

    return Semantics(
      container: true,
      label: '${prayer.label}, ${prayer.translation}, $timeLabel, $status',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          color: completed ? palette.inverse : palette.surface,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: completed ? palette.inverse : palette.line),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: palette.shadow,
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color:
                    completed
                        ? palette.inverseInk.withValues(alpha: 0.12)
                        : palette.surfaceMuted,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(_iconFor(prayer), color: foreground, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        prayer.label,
                        style: textTheme.titleLarge?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        prayer.translation,
                        style: textTheme.bodySmall?.copyWith(color: muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: <Widget>[
                      Icon(
                        time == null
                            ? Icons.schedule_outlined
                            : Icons.access_time_rounded,
                        size: 13,
                        color: muted,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          timeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: muted,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          status,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color:
                                completed
                                    ? foreground.withValues(alpha: 0.78)
                                    : muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message:
                  completed
                      ? 'Mark ${prayer.label} as not completed'
                      : 'Mark ${prayer.label} as completed',
              child: Semantics(
                button: true,
                toggled: completed,
                label:
                    completed
                        ? 'Undo ${prayer.label} completion'
                        : 'Complete ${prayer.label}',
                child: GestureDetector(
                  key: ValueKey<String>('prayer-toggle-${prayer.name}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: onToggle,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 230),
                        curve: Curves.easeOutBack,
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              completed
                                  ? palette.inverseInk
                                  : Colors.transparent,
                          border: Border.all(
                            color:
                                completed
                                    ? palette.inverseInk
                                    : muted.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          transitionBuilder: (
                            Widget child,
                            Animation<double> animation,
                          ) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: Icon(
                            Icons.check_rounded,
                            key: ValueKey<bool>(completed),
                            color: completed ? palette.inverse : muted,
                            size: 21,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
