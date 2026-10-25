import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_palette.dart';
import 'animated_count.dart';
import 'geometric_pattern.dart';
import 'progress_ring.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.completed,
    required this.total,
    required this.onViewHistory,
  });

  final int completed;
  final int total;
  final VoidCallback onViewHistory;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String message = _messageFor(completed);
    final int percent = total == 0 ? 0 : ((completed / total) * 100).round();
    final bool isComplete = total > 0 && completed >= total;
    final Duration motion = AppMotion.resolve(
      context,
      const Duration(milliseconds: 320),
    );

    return Semantics(
      container: true,
      label: 'Today\'s prayer progress. $message',
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
                      Color.lerp(palette.inverse, palette.inverseInk, 0.07)!,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: GeometricPattern(
                color: palette.inverseInk,
                opacity: 0.055,
                spacing: 42,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: motion,
                  curve: AppMotion.enter,
                  opacity: isComplete ? 1 : 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0.72, -0.55),
                        radius: 1.15,
                        colors: <Color>[
                          palette.inverseInk.withValues(alpha: 0.16),
                          palette.inverseInk.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    'TODAY\'S PRAYERS',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: palette.inverseInk.withValues(
                                        alpha: 0.55,
                                      ),
                                    ),
                                  ),
                                ),
                                AnimatedCount(
                                  value: percent,
                                  suffix: '%',
                                  duration: const Duration(milliseconds: 420),
                                  style: textTheme.labelMedium?.copyWith(
                                    color: palette.inverseInk.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: <Widget>[
                                AnimatedCount(
                                  value: completed,
                                  duration: const Duration(milliseconds: 520),
                                  style: textTheme.displayMedium?.copyWith(
                                    color: palette.inverseInk,
                                    height: 0.95,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 7),
                                  child: Text(
                                    'of $total',
                                    style: textTheme.titleMedium?.copyWith(
                                      color: palette.inverseInk.withValues(
                                        alpha: 0.58,
                                      ),
                                      fontWeight: FontWeight.w600,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 190),
                              child: AnimatedSwitcher(
                                duration: AppMotion.resolve(
                                  context,
                                  const Duration(milliseconds: 300),
                                ),
                                switchInCurve: AppMotion.enter,
                                switchOutCurve: AppMotion.exit,
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
                                  message,
                                  key: ValueKey<String>(message),
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: palette.inverseInk.withValues(
                                      alpha: 0.66,
                                    ),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ProgressRing(
                        completed: completed,
                        total: total,
                        progressColor: palette.inverseInk,
                        trackColor: palette.inverseInk.withValues(alpha: 0.17),
                        textColor: palette.inverseInk,
                        size: 88,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: onViewHistory,
                    style: TextButton.styleFrom(
                      foregroundColor: palette.inverseInk,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 8,
                      ),
                      minimumSize: const Size(48, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    iconAlignment: IconAlignment.end,
                    icon: Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: palette.inverseInk.withValues(alpha: 0.7),
                    ),
                    label: Text(
                      'View prayer history',
                      style: textTheme.labelMedium?.copyWith(
                        color: palette.inverseInk.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _messageFor(int completed) {
    switch (completed) {
      case 0:
        return 'A peaceful start. Begin with Fajr when you are ready.';
      case 1:
      case 2:
        return 'A beautiful start to your day. Keep going gently.';
      case 3:
      case 4:
        return 'You are building a consistent habit. Almost there.';
      default:
        return 'Alhamdulillah. All five prayers are complete.';
    }
  }
}
