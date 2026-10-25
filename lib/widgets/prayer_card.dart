import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/prayer.dart';
import '../theme/app_motion.dart';
import '../theme/app_palette.dart';
import '../utils/date_utils.dart';

class PrayerCard extends StatefulWidget {
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
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _successController;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: AppMotion.emphasized,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_reduceMotion) {
      _successController.value = 0;
    }
  }

  @override
  void didUpdateWidget(covariant PrayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.completed && widget.completed && !_reduceMotion) {
      _successController.forward(from: 0);
    } else if (oldWidget.completed && !widget.completed) {
      _successController.value = 0;
    }
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _successController,
      builder: (BuildContext context, Widget? child) {
        final double progress = _successController.value;
        final double pulse =
            progress > 0 && progress < 1 ? math.sin(progress * math.pi) : 0;
        return Transform.translate(
          offset: Offset(0, -2 * pulse),
          child: Transform.scale(
            scale: 1 + 0.01 * pulse,
            child: _buildCard(context, progress, pulse),
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, double progress, double pulse) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Duration motion = AppMotion.resolve(
      context,
      const Duration(milliseconds: 260),
    );
    final Duration quick = AppMotion.resolve(
      context,
      const Duration(milliseconds: 180),
    );
    final bool completed = widget.completed;
    final Color foreground = completed ? palette.inverseInk : palette.ink;
    final Color muted = completed ? palette.inverseMuted : palette.inkMuted;
    final String status = completed ? 'Completed' : 'Not completed';
    final String timeLabel =
        widget.time == null
            ? 'Prayer times unavailable'
            : AppDate.formatTime(widget.time!);

    return Semantics(
      key: ValueKey<String>('prayer-card-${widget.prayer.name}'),
      container: true,
      label:
          '${widget.prayer.label}, ${widget.prayer.translation}, '
          '$timeLabel, $status',
      child: AnimatedContainer(
        duration: motion,
        curve: AppMotion.enter,
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          color: completed ? palette.inverse : palette.surface,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: completed ? palette.inverse : palette.line),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: palette.shadow,
              blurRadius: 18 + pulse * 10,
              offset: const Offset(0, 8),
            ),
            if (pulse > 0)
              BoxShadow(
                color: palette.ink.withValues(alpha: pulse * 0.06),
                blurRadius: 26,
                spreadRadius: pulse * 2,
              ),
          ],
        ),
        child: Row(
          children: <Widget>[
            AnimatedContainer(
              duration: motion,
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color:
                    completed
                        ? palette.inverseInk.withValues(alpha: 0.12)
                        : palette.surfaceMuted,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Transform.rotate(
                angle: pulse * 0.05,
                child: Transform.scale(
                  scale: 1 + pulse * 0.06,
                  child: Icon(
                    _iconFor(widget.prayer),
                    color: foreground,
                    size: 21,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        widget.prayer.label,
                        style: textTheme.titleLarge?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.prayer.translation,
                        style: textTheme.bodySmall?.copyWith(color: muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: <Widget>[
                      Icon(
                        widget.time == null
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
                      ? 'Mark ${widget.prayer.label} as not completed'
                      : 'Mark ${widget.prayer.label} as completed',
              child: Semantics(
                button: true,
                toggled: completed,
                label:
                    completed
                        ? 'Undo ${widget.prayer.label} completion'
                        : 'Complete ${widget.prayer.label}',
                child: GestureDetector(
                  key: ValueKey<String>('prayer-toggle-${widget.prayer.name}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onToggle,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        if (pulse > 0)
                          SizedBox.square(
                            dimension: 58,
                            child: CustomPaint(
                              painter: _CheckPulsePainter(
                                progress: progress,
                                color:
                                    completed
                                        ? palette.inverseInk
                                        : palette.ink,
                              ),
                            ),
                          ),
                        Transform.scale(
                          scale: 1 + pulse * 0.07,
                          child: AnimatedContainer(
                            duration: quick,
                            curve: AppMotion.spring,
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
                              duration: quick,
                              transitionBuilder: (
                                Widget child,
                                Animation<double> animation,
                              ) {
                                return ScaleTransition(
                                  scale: animation.drive(
                                    CurveTween(curve: AppMotion.spring),
                                  ),
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
                      ],
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

class _CheckPulsePainter extends CustomPainter {
  const _CheckPulsePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) {
      return;
    }
    final Offset center = size.center(Offset.zero);
    final double radius = 20 + progress * 9;
    final double opacity = (1 - progress) * 0.38;
    final Paint paint =
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckPulsePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
