import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../controllers/compass_controller.dart';
import '../../controllers/prayer_times_controller.dart';
import '../../models/saved_location.dart';
import '../../theme/app_palette.dart';
import '../../utils/date_utils.dart';
import '../../widgets/location_sheet.dart';

class CompassView extends StatefulWidget {
  const CompassView({
    super.key,
    required this.compassController,
    required this.prayerTimesController,
    required this.isActive,
  });

  final CompassController compassController;
  final PrayerTimesController prayerTimesController;
  final bool isActive;

  @override
  State<CompassView> createState() => _CompassViewState();
}

class _CompassViewState extends State<CompassView> with WidgetsBindingObserver {
  bool _appActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.prayerTimesController.addListener(_syncActive);
    _syncActive();
  }

  @override
  void didUpdateWidget(covariant CompassView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prayerTimesController != widget.prayerTimesController) {
      oldWidget.prayerTimesController.removeListener(_syncActive);
      widget.prayerTimesController.addListener(_syncActive);
    }
    _syncActive();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appActive = state == AppLifecycleState.resumed;
    _syncActive();
  }

  void _syncActive() {
    final bool shouldRun =
        widget.isActive &&
        _appActive &&
        widget.prayerTimesController.hasLocation &&
        widget.compassController.qiblaBearing != null;
    widget.compassController.setActive(shouldRun);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.prayerTimesController.removeListener(_syncActive);
    widget.compassController.setActive(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        widget.compassController,
        widget.prayerTimesController,
      ]),
      builder: (BuildContext context, Widget? child) {
        final PrayerTimesController prayerTimes = widget.prayerTimesController;
        final CompassController compass = widget.compassController;
        final SavedLocation? location = prayerTimes.location;

        return CustomScrollView(
          key: const ValueKey<String>('compass-view'),
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'QIBLA',
                          style: textTheme.labelSmall?.copyWith(
                            color: palette.inkMuted,
                            fontSize: 9,
                            letterSpacing: 1.35,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Face the Kaaba',
                          style: textTheme.displayMedium?.copyWith(
                            fontSize: 44,
                            letterSpacing: -0.7,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hold your phone flat and away from metal objects for the steadiest reading.',
                          style: textTheme.bodySmall?.copyWith(
                            color: palette.inkMuted,
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (location != null)
                          _LocationChip(
                            location: location,
                            onChange:
                                () => LocationSheet.show(context, prayerTimes),
                          ),
                        if (location != null) const SizedBox(height: 14),
                        if (location == null)
                          _QiblaLocationGate(
                            onOpenLocation:
                                () => LocationSheet.show(context, prayerTimes),
                          )
                        else if (compass.qiblaBearing == null)
                          _QiblaLocationGate(
                            onOpenLocation:
                                () => LocationSheet.show(context, prayerTimes),
                          )
                        else
                          _CompassCard(
                            compass: compass,
                            qiblaBearing: compass.qiblaBearing!,
                          ),
                        if (location != null) ...<Widget>[
                          const SizedBox(height: 14),
                          _CompassNote(
                            location: location,
                            qiblaBearing: compass.qiblaBearing,
                          ),
                        ],
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: palette.surfaceMuted,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.explore_outlined,
                                size: 16,
                                color: palette.inkMuted,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  'The Qibla is calculated as a great-circle bearing from your saved location. Magnetic fields and nearby metal can affect a phone compass.',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: palette.inkMuted,
                                    fontSize: 11,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({required this.location, required this.onChange});

  final SavedLocation location;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: palette.line),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.location_on_outlined, size: 15, color: palette.ink),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${location.label} · ${AppDate.formatCoordinates(location.latitude, location.longitude)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: palette.inkMuted,
                fontSize: 10.5,
              ),
            ),
          ),
          TextButton(
            onPressed: onChange,
            style: TextButton.styleFrom(
              minimumSize: const Size(48, 34),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

class _QiblaLocationGate extends StatelessWidget {
  const _QiblaLocationGate({required this.onOpenLocation});

  final VoidCallback onOpenLocation;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: palette.line),
      ),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: 148,
                height: 148,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.surfaceMuted,
                  border: Border.all(color: palette.line),
                ),
              ),
              Container(
                width: 106,
                height: 106,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.line, width: 1),
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: palette.ink,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.explore_rounded,
                  color: palette.inverseInk,
                  size: 26,
                ),
              ),
              Positioned(
                top: 3,
                child: Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 29,
                  color: palette.inkMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Find your Qibla',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(
              'Set your prayer location to calculate the direction to the Kaaba. Location is used only on this device.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: palette.inkMuted,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 260,
            child: OutlinedButton.icon(
              onPressed: onOpenLocation,
              icon: const Icon(Icons.location_on_outlined, size: 18),
              label: const Text('Set prayer location'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassCard extends StatelessWidget {
  const _CompassCard({required this.compass, required this.qiblaBearing});

  final CompassController compass;
  final double qiblaBearing;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isReady = compass.sensorState == CompassSensorState.ready;
    final double? heading = compass.heading;
    final bool isAligned = compass.isAligned;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isAligned ? palette.ink : palette.line,
          width: isAligned ? 1.6 : 1,
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'QIBLA BEARING',
                style: textTheme.labelSmall?.copyWith(
                  color: palette.inkMuted,
                  fontSize: 9,
                ),
              ),
              const Spacer(),
              Text(
                '${qiblaBearing.toStringAsFixed(1)}°',
                style: textTheme.labelMedium?.copyWith(
                  color: palette.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'from north',
                style: textTheme.labelSmall?.copyWith(
                  color: palette.inkMuted,
                  fontSize: 8,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double dialSize = math.min(
                constraints.maxWidth,
                constraints.maxHeight.isFinite && constraints.maxHeight > 0
                    ? constraints.maxHeight
                    : 320,
              );
              return SizedBox.square(
                dimension: dialSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    if (isReady && heading != null)
                      Transform.rotate(
                        angle: -heading * math.pi / 180,
                        child: SizedBox.square(
                          dimension: dialSize,
                          child: CustomPaint(
                            painter: _CompassDialPainter(
                              qiblaBearing: qiblaBearing,
                              background: palette.surfaceMuted,
                              ink: palette.ink,
                              muted: palette.inkMuted,
                              line: palette.line,
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox.square(
                        dimension: dialSize,
                        child: CustomPaint(
                          painter: _CompassDialPainter(
                            qiblaBearing: qiblaBearing,
                            background: palette.surfaceMuted,
                            ink: palette.ink,
                            muted: palette.inkMuted,
                            line: palette.line,
                          ),
                        ),
                      ),
                    Positioned(top: 0, child: _TopPointer(color: palette.ink)),
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: palette.ink,
                        border: Border.all(color: palette.surface, width: 4),
                      ),
                      child: Icon(
                        Icons.mosque_rounded,
                        size: 23,
                        color: palette.inverseInk,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _CompassStatus(
              key: ValueKey<String>('${compass.sensorState}-$isAligned'),
              state: compass.sensorState,
              angle: compass.relativeQiblaAngle,
              aligned: isAligned,
              accuracy: compass.accuracy,
              errorMessage: compass.sensorError,
              onRetry: compass.retry,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopPointer extends StatelessWidget {
  const _TopPointer({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 13),
      painter: _PointerPainter(color),
    );
  }
}

class _PointerPainter extends CustomPainter {
  const _PointerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path =
        Path()
          ..moveTo(size.width / 2, size.height)
          ..lineTo(0, 0)
          ..lineTo(size.width, 0)
          ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _CompassStatus extends StatelessWidget {
  const _CompassStatus({
    super.key,
    required this.state,
    required this.angle,
    required this.aligned,
    required this.accuracy,
    required this.errorMessage,
    required this.onRetry,
  });

  final CompassSensorState state;
  final double? angle;
  final bool aligned;
  final double? accuracy;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (state == CompassSensorState.unavailable) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: palette.surfaceMuted,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.sensors_off_outlined, size: 17, color: palette.ink),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage ??
                        'The compass sensor is not available on this device.',
                    style: textTheme.bodySmall?.copyWith(
                      color: palette.inkMuted,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 15),
              label: const Text('Try again'),
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 38),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      );
    }

    if (state == CompassSensorState.waiting || angle == null) {
      return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: palette.inkMuted,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Listening to your compass…',
                style: textTheme.bodySmall?.copyWith(color: palette.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            'Move your phone in a gentle figure eight to calibrate.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: palette.inkMuted,
              fontSize: 10.5,
            ),
          ),
        ],
      );
    }

    final double shortest = angle! <= 180 ? angle! : 360 - angle!;
    final bool turnRight = angle! <= 180;
    final int degrees = shortest.round();
    final bool lowAccuracy = accuracy != null && accuracy! > 25;

    return Column(
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: aligned ? palette.ink : palette.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                aligned
                    ? Icons.check_circle_outline_rounded
                    : Icons.rotate_right_rounded,
                size: 15,
                color: aligned ? palette.inverseInk : palette.ink,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  aligned
                      ? 'Facing the Qibla'
                      : degrees <= 1
                      ? 'Almost aligned'
                      : 'Turn ${turnRight ? 'right' : 'left'} $degrees°',
                  textAlign: TextAlign.center,
                  style: textTheme.labelMedium?.copyWith(
                    color: aligned ? palette.inverseInk : palette.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Text(
          aligned
              ? 'Your phone is aligned with Makkah.'
              : lowAccuracy
              ? 'Compass accuracy is low. Move away from metal and recalibrate.'
              : 'Keep the phone flat as you turn.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: palette.inkMuted,
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }
}

class _CompassNote extends StatelessWidget {
  const _CompassNote({required this.location, required this.qiblaBearing});

  final SavedLocation location;
  final double? qiblaBearing;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.line),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: palette.surfaceMuted,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              location.source == LocationSource.device
                  ? Icons.my_location_rounded
                  : Icons.edit_location_alt_outlined,
              size: 17,
              color: palette.ink,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  location.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppDate.formatCoordinates(location.latitude, location.longitude)}'
                  '${qiblaBearing == null ? '' : ' · ${qiblaBearing!.toStringAsFixed(1)}° bearing'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: palette.inkMuted,
                    fontSize: 9,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          Text(
            location.source == LocationSource.device ? 'Device' : 'Manual',
            style: textTheme.labelSmall?.copyWith(
              color: palette.inkMuted,
              fontSize: 8,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  const _CompassDialPainter({
    required this.qiblaBearing,
    required this.background,
    required this.ink,
    required this.muted,
    required this.line,
  });

  final double qiblaBearing;
  final Color background;
  final Color ink;
  final Color muted;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.width / 2) - 3;
    final Paint fill = Paint()..color = background;
    final Paint ring =
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    final Paint tick =
        Paint()
          ..color = muted
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, fill);
    canvas.drawCircle(center, radius, ring);
    canvas.drawCircle(center, radius * 0.86, ring);
    canvas.drawCircle(center, radius * 0.37, ring);

    for (int index = 0; index < 72; index++) {
      final double angle = index * 5 * math.pi / 180;
      final bool isCardinal = index % 18 == 0;
      final bool isMajor = index % 6 == 0;
      final double length =
          isCardinal
              ? radius * 0.075
              : isMajor
              ? radius * 0.05
              : radius * 0.025;
      final Offset direction = Offset(math.sin(angle), -math.cos(angle));
      tick
        ..color = isCardinal ? ink : muted.withValues(alpha: 0.5)
        ..strokeWidth = isCardinal ? 2 : 1;
      canvas.drawLine(
        center + direction * (radius * 0.88),
        center + direction * (radius * 0.88 - length),
        tick,
      );
    }

    final List<String> labels = <String>['N', 'E', 'S', 'W'];
    for (int index = 0; index < labels.length; index++) {
      final double angle = index * 90 * math.pi / 180;
      final Offset point = center.translate(
        math.sin(angle) * radius * 0.68,
        -math.cos(angle) * radius * 0.68,
      );
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: labels[index],
          style: TextStyle(
            fontFamily: 'Manrope',
            color: index == 0 ? ink : muted,
            fontSize: radius * 0.065,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        point - Offset(painter.width / 2, painter.height / 2),
      );
    }

    final double qiblaAngle = qiblaBearing * math.pi / 180;
    final Offset direction = Offset(
      math.sin(qiblaAngle),
      -math.cos(qiblaAngle),
    );
    final Offset tangent = Offset(-math.cos(qiblaAngle), -math.sin(qiblaAngle));
    final Offset lineStart = center + direction * (radius * 0.33);
    final Offset markerBase = center + direction * (radius * 0.76);
    final Offset markerTip = center + direction * (radius * 0.92);

    canvas.drawLine(
      lineStart,
      markerBase,
      Paint()
        ..color = ink.withValues(alpha: 0.45)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );

    final Path qiblaMarker =
        Path()
          ..moveTo(markerTip.dx, markerTip.dy)
          ..lineTo(
            markerBase.dx + tangent.dx * radius * 0.06,
            markerBase.dy + tangent.dy * radius * 0.06,
          )
          ..lineTo(
            markerBase.dx - tangent.dx * radius * 0.06,
            markerBase.dy - tangent.dy * radius * 0.06,
          )
          ..close();
    canvas.drawPath(qiblaMarker, Paint()..color = ink);

    _drawStar(
      canvas,
      center + direction * (radius * 0.57),
      radius * 0.045,
      ink,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final Path star = Path();
    for (int index = 0; index < 8; index++) {
      final double angle = (-90 + index * 45) * math.pi / 180;
      final double r = index.isEven ? radius : radius * 0.32;
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
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) {
    return oldDelegate.qiblaBearing != qiblaBearing ||
        oldDelegate.background != background ||
        oldDelegate.ink != ink ||
        oldDelegate.muted != muted ||
        oldDelegate.line != line;
  }
}
