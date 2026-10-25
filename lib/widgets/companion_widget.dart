import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/streak_summary.dart';
import '../theme/app_palette.dart';
import '../utils/date_utils.dart';

enum CompanionMood { welcoming, attentive, celebrating, proud, comforting }

class CompanionWidget extends StatefulWidget {
  const CompanionWidget({
    super.key,
    required this.summary,
    this.onOpenCalendar,
  });

  final StreakSummary summary;
  final VoidCallback? onOpenCalendar;

  @override
  State<CompanionWidget> createState() => _CompanionWidgetState();
}

class _CompanionWidgetState extends State<CompanionWidget>
    with TickerProviderStateMixin {
  static const Set<int> _milestones = <int>{1, 3, 7, 14, 30};
  static const Duration _idleDuration = Duration(milliseconds: 5600);

  late final AnimationController _idleController;
  late final AnimationController _reactionController;
  late final AnimationController _celebrationController;
  late final Listenable _animation;
  final Set<String> _celebratedKeys = <String>{};

  late StreakSummary _previousSummary;
  bool _animationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _previousSummary = widget.summary;
    _idleController = AnimationController(vsync: this, duration: _idleDuration);
    _reactionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );
    _animation = Listenable.merge(<Listenable>[
      _idleController,
      _reactionController,
      _celebrationController,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimations(enabled: !MediaQuery.of(context).disableAnimations);
  }

  void _syncAnimations({required bool enabled}) {
    _animationsEnabled = enabled;
    if (enabled) {
      if (!_idleController.isAnimating) {
        _idleController.repeat();
      }
      return;
    }
    _idleController
      ..stop()
      ..value = 0;
    _reactionController
      ..stop()
      ..value = 0;
    _celebrationController
      ..stop()
      ..value = 0;
  }

  @override
  void didUpdateWidget(covariant CompanionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final StreakSummary previous = _previousSummary;
    _previousSummary = widget.summary;
    final bool celebrated = _maybeCelebrate(previous, widget.summary);
    final bool moodChanged = _moodFor(previous) != _moodFor(widget.summary);
    if (!celebrated &&
        moodChanged &&
        _animationsEnabled &&
        TickerMode.of(context)) {
      _reactionController.forward(from: 0);
    }
  }

  bool _maybeCelebrate(StreakSummary previous, StreakSummary current) {
    if (!_animationsEnabled || !TickerMode.of(context)) {
      return false;
    }
    final String dayKey = AppDate.dateKey(current.date);
    bool shouldCelebrate = false;

    if (!previous.todayComplete && current.todayComplete) {
      if (_celebratedKeys.add('complete-$dayKey')) {
        shouldCelebrate = true;
      }
    }

    if (current.currentStreak > previous.currentStreak &&
        _milestones.contains(current.currentStreak)) {
      if (_celebratedKeys.add('streak-${current.currentStreak}-$dayKey')) {
        shouldCelebrate = true;
      }
    }

    if (shouldCelebrate) {
      _celebrationController.forward(from: 0);
      HapticFeedback.mediumImpact();
    }
    return shouldCelebrate;
  }

  double _pulse(double value, double start, double end) {
    if (value < start || value > end) {
      return 0;
    }
    final double progress = (value - start) / (end - start);
    return math.sin(progress * math.pi);
  }

  double _blinkAt(double value) {
    return math.max(_pulse(value, 0.55, 0.59), _pulse(value, 0.86, 0.895));
  }

  double _wingBaseFor(CompanionMood mood) {
    switch (mood) {
      case CompanionMood.welcoming:
        return 0.02;
      case CompanionMood.attentive:
        return 0.04;
      case CompanionMood.celebrating:
        return 0.09;
      case CompanionMood.proud:
        return 0.06;
      case CompanionMood.comforting:
        return -0.045;
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _reactionController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final CompanionMood mood = _moodFor(widget.summary);
    final _CompanionCopy copy = _copyFor(mood, widget.summary);

    return Semantics(
      container: true,
      label: '${copy.title}. ${copy.message}',
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 16, 14),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: palette.line),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AnimatedBuilder(
              animation: _animation,
              builder: (BuildContext context, Widget? child) {
                final bool animate = _animationsEnabled;
                final double idle = animate ? _idleController.value : 0;
                final double breathe =
                    animate ? math.sin(idle * math.pi * 2) : 0;
                final double blink = animate ? _blinkAt(idle) : 0;
                final double gaze =
                    animate ? math.sin(idle * math.pi * 2 + 1.2) * 0.75 : 0;
                final double flutter =
                    animate
                        ? math.max(
                          _pulse(idle, 0.18, 0.235),
                          _pulse(idle, 0.7, 0.755),
                        )
                        : 0;
                final double reaction =
                    animate ? math.sin(_reactionController.value * math.pi) : 0;
                final double celebration =
                    animate ? _celebrationController.value : 0;
                final bool isCelebrating = celebration > 0 && celebration < 1;
                final double celebrationPulse =
                    isCelebrating ? math.sin(celebration * math.pi) : 0;
                final double celebrationFlutter =
                    isCelebrating
                        ? math.sin(celebration * math.pi * 6) *
                            (1 - celebration)
                        : 0;
                final double lift = reaction * 3 + celebrationPulse * 6;
                final double rotation =
                    math.sin(idle * math.pi * 2 - 0.7) * 0.012 +
                    reaction * 0.025 +
                    celebrationFlutter * 0.018;
                final double wingAngle =
                    _wingBaseFor(mood) +
                    math.sin(idle * math.pi * 2 + 0.4) * 0.035 +
                    flutter * 0.12 +
                    reaction * 0.14 +
                    celebrationFlutter * 0.24;
                final double starPulse =
                    animate ? math.sin(idle * math.pi * 2 - 1.1) : 0;
                final double sparkle =
                    animate
                        ? 0.5 + 0.5 * math.sin(idle * math.pi * 4 + 0.4)
                        : 0;

                return Transform.translate(
                  key: const ValueKey<String>('companion-motion'),
                  offset: Offset(0, breathe * 2.2 - lift),
                  child: Transform.rotate(
                    angle: rotation,
                    child: Transform.scale(
                      scale: 1 + celebrationPulse * 0.055 + reaction * 0.012,
                      child: RepaintBoundary(
                        child: SizedBox.square(
                          dimension: 98,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              SizedBox.square(
                                dimension: 88,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: palette.surfaceMuted,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Transform.scale(
                                scale: 1 + breathe * 0.012,
                                alignment: Alignment.bottomCenter,
                                child: CustomPaint(
                                  size: const Size.square(88),
                                  painter: _OwlPainter(
                                    mood: mood,
                                    blink: blink,
                                    gaze: gaze,
                                    wingAngle: wingAngle,
                                    starPulse: starPulse,
                                    sparkle: sparkle,
                                    body: palette.ink,
                                    face: palette.surface,
                                    muted: palette.inkMuted,
                                  ),
                                ),
                              ),
                              if (isCelebrating)
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _CelebrationPainter(
                                      progress: celebration,
                                      primary: palette.ink,
                                      secondary: palette.inkMuted,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'YOUR COMPANION',
                    style: textTheme.labelSmall?.copyWith(
                      color: palette.inkMuted,
                      fontSize: 9,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  AnimatedSize(
                    duration:
                        _animationsEnabled
                            ? const Duration(milliseconds: 280)
                            : Duration.zero,
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topLeft,
                    child: AnimatedSwitcher(
                      duration:
                          _animationsEnabled
                              ? const Duration(milliseconds: 280)
                              : Duration.zero,
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      layoutBuilder: (
                        Widget? currentChild,
                        List<Widget> previousChildren,
                      ) {
                        return Stack(
                          alignment: AlignmentDirectional.topStart,
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                      ) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.08),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        key: ValueKey<String>('${copy.title}|${copy.message}'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            copy.title,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            copy.message,
                            style: textTheme.bodySmall?.copyWith(
                              color: palette.inkMuted,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: palette.surfaceMuted,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.local_fire_department_outlined,
                              size: 13,
                              color: palette.ink,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppDate.formatDays(widget.summary.currentStreak),
                              style: textTheme.labelSmall?.copyWith(
                                color: palette.ink,
                                letterSpacing: 0.1,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.onOpenCalendar != null)
                        GestureDetector(
                          onTap: widget.onOpenCalendar,
                          child: Semantics(
                            button: true,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Prayer history',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: palette.ink,
                                      letterSpacing: 0.1,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 13,
                                    color: palette.ink,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  CompanionMood _moodFor(StreakSummary summary) {
    if (summary.isStreakBroken) {
      return CompanionMood.comforting;
    }
    if (summary.todayComplete) {
      return summary.currentStreak >= 7
          ? CompanionMood.proud
          : CompanionMood.celebrating;
    }
    if (summary.todayCompleted > 0) {
      return CompanionMood.attentive;
    }
    return CompanionMood.welcoming;
  }

  _CompanionCopy _copyFor(CompanionMood mood, StreakSummary summary) {
    switch (mood) {
      case CompanionMood.welcoming:
        return const _CompanionCopy(
          'A gentle beginning',
          'Your first prayer is waiting. There is no rush.',
        );
      case CompanionMood.attentive:
        return const _CompanionCopy(
          'One prayer at a time',
          'You are doing beautifully. Keep your intention close.',
        );
      case CompanionMood.celebrating:
        if (summary.currentStreak <= 1) {
          return const _CompanionCopy(
            'Your first complete day',
            'MashaAllah. Every prayer is complete today.',
          );
        }
        return const _CompanionCopy(
          'A full day of prayer',
          'MashaAllah. Every prayer is complete today.',
        );
      case CompanionMood.proud:
        return _CompanionCopy(
          'A steady heart',
          'MashaAllah. ${summary.currentStreak} days of consistent prayer.',
        );
      case CompanionMood.comforting:
        return const _CompanionCopy(
          'Begin again, gently',
          'A missed day does not erase your effort. Tomorrow is a new beginning.',
        );
    }
  }
}

class _CompanionCopy {
  const _CompanionCopy(this.title, this.message);

  final String title;
  final String message;
}

class _OwlPainter extends CustomPainter {
  const _OwlPainter({
    required this.mood,
    required this.blink,
    required this.gaze,
    required this.wingAngle,
    required this.starPulse,
    required this.sparkle,
    required this.body,
    required this.face,
    required this.muted,
  });

  final CompanionMood mood;
  final double blink;
  final double gaze;
  final double wingAngle;
  final double starPulse;
  final double sparkle;
  final Color body;
  final Color face;
  final Color muted;

  @override
  void paint(Canvas canvas, Size size) {
    final double unit = size.width / 100;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final Paint bodyPaint = Paint()..color = body;
    final Paint facePaint = Paint()..color = face;
    final Paint linePaint =
        Paint()
          ..color = body
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2 * unit
          ..strokeCap = StrokeCap.round;

    final Offset bodyCenter = center.translate(0, 3 * unit);
    final Rect bodyRect = Rect.fromCenter(
      center: bodyCenter,
      width: 51 * unit,
      height: 56 * unit,
    );
    canvas.drawOval(bodyRect, bodyPaint);

    final Path leftEar =
        Path()
          ..moveTo(28 * unit, 28 * unit)
          ..lineTo(35 * unit, 11 * unit)
          ..lineTo(43 * unit, 27 * unit)
          ..close();
    final Path rightEar =
        Path()
          ..moveTo(57 * unit, 27 * unit)
          ..lineTo(65 * unit, 11 * unit)
          ..lineTo(72 * unit, 28 * unit)
          ..close();
    canvas.drawPath(leftEar, bodyPaint);
    canvas.drawPath(rightEar, bodyPaint);

    _drawWing(
      canvas,
      paint: bodyPaint,
      shoulder: center.translate(-19 * unit, -8 * unit),
      unit: unit,
      isLeft: true,
    );
    _drawWing(
      canvas,
      paint: bodyPaint,
      shoulder: center.translate(19 * unit, -8 * unit),
      unit: unit,
      isLeft: false,
    );

    final Offset leftEyeCenter = center.translate(-11.5 * unit, -4 * unit);
    final Offset rightEyeCenter = center.translate(11.5 * unit, -4 * unit);
    canvas.drawCircle(leftEyeCenter, 14 * unit, facePaint);
    canvas.drawCircle(rightEyeCenter, 14 * unit, facePaint);

    final double openAmount = (1 - blink / 0.6).clamp(0.0, 1.0);
    final double closedAmount = ((blink - 0.4) / 0.6).clamp(0.0, 1.0);
    final Paint eyeLinePaint =
        Paint()
          ..color = body.withValues(alpha: openAmount)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2 * unit
          ..strokeCap = StrokeCap.round;
    final Paint pupilPaint =
        Paint()..color = body.withValues(alpha: openAmount);
    final Paint highlightPaint =
        Paint()..color = face.withValues(alpha: openAmount);
    final Offset gazeOffset = Offset(gaze * 1.7 * unit, 0);

    switch (mood) {
      case CompanionMood.celebrating:
        _drawHappyEye(canvas, leftEyeCenter, unit, eyeLinePaint);
        _drawHappyEye(canvas, rightEyeCenter, unit, eyeLinePaint);
      case CompanionMood.proud:
        _drawProudEye(canvas, leftEyeCenter, unit, eyeLinePaint);
        _drawProudEye(canvas, rightEyeCenter, unit, eyeLinePaint);
      case CompanionMood.comforting:
        _drawSoftEye(canvas, leftEyeCenter, unit, eyeLinePaint);
        _drawSoftEye(canvas, rightEyeCenter, unit, eyeLinePaint);
      case CompanionMood.attentive:
        canvas.drawCircle(leftEyeCenter + gazeOffset, 5.4 * unit, pupilPaint);
        canvas.drawCircle(rightEyeCenter + gazeOffset, 5.4 * unit, pupilPaint);
        canvas.drawCircle(
          leftEyeCenter + gazeOffset + Offset(-1.8 * unit, -1.7 * unit),
          1.35 * unit,
          highlightPaint,
        );
        canvas.drawCircle(
          rightEyeCenter + gazeOffset + Offset(-1.8 * unit, -1.7 * unit),
          1.35 * unit,
          highlightPaint,
        );
      case CompanionMood.welcoming:
        canvas.drawCircle(leftEyeCenter + gazeOffset, 4.4 * unit, pupilPaint);
        canvas.drawCircle(rightEyeCenter + gazeOffset, 4.4 * unit, pupilPaint);
        canvas.drawCircle(
          leftEyeCenter + gazeOffset + Offset(-1.4 * unit, -1.3 * unit),
          1.15 * unit,
          highlightPaint,
        );
        canvas.drawCircle(
          rightEyeCenter + gazeOffset + Offset(-1.4 * unit, -1.3 * unit),
          1.15 * unit,
          highlightPaint,
        );
    }

    if (closedAmount > 0) {
      final Paint closedEyePaint =
          Paint()
            ..color = body.withValues(alpha: closedAmount)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2 * unit
            ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        leftEyeCenter.translate(-6 * unit, 0),
        leftEyeCenter.translate(6 * unit, 0),
        closedEyePaint,
      );
      canvas.drawLine(
        rightEyeCenter.translate(-6 * unit, 0),
        rightEyeCenter.translate(6 * unit, 0),
        closedEyePaint,
      );
    }

    final Path beak =
        Path()
          ..moveTo(center.dx, 7 * unit)
          ..lineTo(center.dx - 4 * unit, 12 * unit)
          ..lineTo(center.dx + 4 * unit, 12 * unit)
          ..close();
    canvas.drawPath(beak, Paint()..color = body);

    if (mood == CompanionMood.comforting) {
      canvas.drawLine(
        center.translate(-24 * unit, -22 * unit),
        center.translate(-19 * unit, -25 * unit),
        linePaint,
      );
      canvas.drawLine(
        center.translate(24 * unit, -22 * unit),
        center.translate(19 * unit, -25 * unit),
        linePaint,
      );
    }

    _drawChestStar(
      canvas,
      center.translate(0, 27 * unit),
      unit,
      pulse: starPulse,
    );

    linePaint.strokeWidth = 1.9 * unit;
    canvas.drawLine(
      center.translate(-10 * unit, 32 * unit),
      center.translate(-10 * unit, 37 * unit),
      linePaint,
    );
    canvas.drawLine(
      center.translate(10 * unit, 32 * unit),
      center.translate(10 * unit, 37 * unit),
      linePaint,
    );

    if (mood == CompanionMood.proud || mood == CompanionMood.celebrating) {
      _drawSparkle(
        canvas,
        center.translate(-35 * unit, -23 * unit),
        4.3 * unit * (1 + sparkle * 0.18),
        muted.withValues(alpha: 0.55 + sparkle * 0.45),
      );
      _drawSparkle(
        canvas,
        center.translate(37 * unit, -14 * unit),
        3.1 * unit * (1 + sparkle * 0.15),
        muted.withValues(alpha: 0.45 + sparkle * 0.4),
      );
    }
  }

  void _drawWing(
    Canvas canvas, {
    required Paint paint,
    required Offset shoulder,
    required double unit,
    required bool isLeft,
  }) {
    canvas.save();
    canvas.translate(shoulder.dx, shoulder.dy);
    canvas.rotate(isLeft ? wingAngle : -wingAngle);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset((isLeft ? -3 : 3) * unit, 15.5 * unit),
        width: 17 * unit,
        height: 32 * unit,
      ),
      paint,
    );
    canvas.restore();
  }

  void _drawHappyEye(Canvas canvas, Offset center, double unit, Paint paint) {
    final Path path =
        Path()
          ..moveTo(center.dx - 5.5 * unit, center.dy + 1.5 * unit)
          ..quadraticBezierTo(
            center.dx,
            center.dy - 5 * unit,
            center.dx + 5.5 * unit,
            center.dy + 1.5 * unit,
          );
    canvas.drawPath(path, paint);
  }

  void _drawProudEye(Canvas canvas, Offset center, double unit, Paint paint) {
    canvas.drawLine(
      center.translate(-5.5 * unit, 0),
      center.translate(5.5 * unit, 0),
      paint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: center.translate(0, 2 * unit),
        width: 11 * unit,
        height: 9 * unit,
      ),
      0.2,
      math.pi - 0.4,
      false,
      paint,
    );
  }

  void _drawSoftEye(Canvas canvas, Offset center, double unit, Paint paint) {
    final Path path =
        Path()
          ..moveTo(center.dx - 5 * unit, center.dy)
          ..quadraticBezierTo(
            center.dx,
            center.dy + 4 * unit,
            center.dx + 5 * unit,
            center.dy,
          );
    canvas.drawPath(path, paint);
  }

  void _drawChestStar(
    Canvas canvas,
    Offset center,
    double unit, {
    required double pulse,
  }) {
    final Path star = Path();
    final double pulseScale = 1 + pulse * 0.14;
    for (int index = 0; index < 8; index++) {
      final double angle = (-90 + index * 45) * math.pi / 180;
      final double radius =
          (index.isEven ? 3.8 * unit : 1.3 * unit) * pulseScale;
      final Offset point = center.translate(
        radius * math.cos(angle),
        radius * math.sin(angle),
      );
      if (index == 0) {
        star.moveTo(point.dx, point.dy);
      } else {
        star.lineTo(point.dx, point.dy);
      }
    }
    star.close();
    canvas.drawPath(star, Paint()..color = face);
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Color color) {
    final Path star = Path();
    for (int index = 0; index < 8; index++) {
      final double angle = (-90 + index * 45) * math.pi / 180;
      final double r = index.isEven ? radius : radius * 0.3;
      final Offset point = center.translate(
        r * math.cos(angle),
        r * math.sin(angle),
      );
      if (index == 0) {
        star.moveTo(point.dx, point.dy);
      } else {
        star.lineTo(point.dx, point.dy);
      }
    }
    star.close();
    canvas.drawPath(star, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _OwlPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.blink != blink ||
        oldDelegate.gaze != gaze ||
        oldDelegate.wingAngle != wingAngle ||
        oldDelegate.starPulse != starPulse ||
        oldDelegate.sparkle != sparkle ||
        oldDelegate.body != body ||
        oldDelegate.face != face ||
        oldDelegate.muted != muted;
  }
}

class _CelebrationPainter extends CustomPainter {
  const _CelebrationPainter({
    required this.progress,
    required this.primary,
    required this.secondary,
  });

  final double progress;
  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) {
      return;
    }
    final Offset center = size.center(Offset.zero);
    final double fade = math.sin(progress * math.pi);
    for (int index = 0; index < 10; index++) {
      final double angle = index * math.pi * 2 / 10 + 0.25;
      final double distance = 26 + (progress * 28);
      final double wobble = math.sin(progress * math.pi * 2 + index) * 4;
      final Offset point = center.translate(
        math.cos(angle) * (distance + wobble),
        math.sin(angle) * (distance + wobble) - (progress * 8),
      );
      final Color color = index.isEven ? primary : secondary;
      canvas.drawCircle(
        point,
        (index.isEven ? 2.3 : 1.6),
        Paint()..color = color.withValues(alpha: fade * 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary;
  }
}
