import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/compass_sensor_service.dart';
import '../services/qibla_service.dart';
import 'prayer_times_controller.dart';

enum CompassSensorState { idle, waiting, ready, unavailable }

class CompassController extends ChangeNotifier {
  CompassController({
    required PrayerTimesController prayerTimesController,
    CompassHeadingSource headingSource = const FlutterCompassHeadingSource(),
    Duration sensorTimeout = const Duration(seconds: 5),
  }) : _prayerTimesController = prayerTimesController,
       _headingSource = headingSource,
       _sensorTimeout = sensorTimeout {
    _prayerTimesController.addListener(_handleLocationChanged);
    _updateQiblaBearing();
  }

  final PrayerTimesController _prayerTimesController;
  final CompassHeadingSource _headingSource;
  final Duration _sensorTimeout;

  StreamSubscription<CompassReading>? _subscription;
  Timer? _timeoutTimer;

  bool _active = false;
  bool _disposed = false;
  CompassSensorState _sensorState = CompassSensorState.idle;
  double? _heading;
  double? _unwrappedHeading;
  double? _accuracy;
  double? _qiblaBearing;
  String? _sensorError;

  bool get isActive => _active;
  CompassSensorState get sensorState => _sensorState;
  double? get heading => _heading;
  double? get unwrappedHeading => _unwrappedHeading;
  double? get accuracy => _accuracy;
  double? get qiblaBearing => _qiblaBearing;
  String? get sensorError => _sensorError;
  bool get hasHeading => _heading != null;
  bool get hasQibla => _qiblaBearing != null;

  double? get relativeQiblaAngle {
    final double? qibla = _qiblaBearing;
    final double? heading = _heading;
    if (qibla == null || heading == null) {
      return null;
    }
    return QiblaService.relativeAngle(
      qiblaBearing: qibla,
      deviceHeading: heading,
    );
  }

  bool get isAligned {
    final double? qibla = _qiblaBearing;
    final double? heading = _heading;
    if (qibla == null || heading == null) {
      return false;
    }
    return QiblaService.isAligned(qiblaBearing: qibla, deviceHeading: heading);
  }

  void setActive(bool active) {
    if (_active == active) {
      return;
    }
    _active = active;
    if (active) {
      _startSensor();
    } else {
      _stopSensor();
    }
  }

  void retry() {
    if (!_active) {
      return;
    }
    _stopSensor(notify: false);
    _startSensor();
  }

  void _startSensor() {
    _subscription?.cancel();
    _timeoutTimer?.cancel();
    _subscription = null;
    _heading = null;
    _unwrappedHeading = null;
    _accuracy = null;
    _sensorError = null;
    _sensorState = CompassSensorState.waiting;
    _notify();

    final Timer timeout = Timer(_sensorTimeout, () {
      if (_active &&
          _sensorState == CompassSensorState.waiting &&
          !hasHeading) {
        _markUnavailable('No compass readings were received from this device.');
      }
    });
    _timeoutTimer = timeout;

    try {
      _subscription = _headingSource.readings.listen(
        _handleReading,
        onError: (Object error) {
          _markUnavailable(
            'The compass sensor is not available on this device.',
          );
        },
        onDone: () {
          if (_sensorState == CompassSensorState.waiting && !hasHeading) {
            _markUnavailable(
              'The compass sensor is not available on this device.',
            );
          }
        },
      );
    } on Object {
      _markUnavailable('The compass sensor could not be started.');
    }
  }

  void _handleReading(CompassReading reading) {
    final double? rawHeading = reading.heading;
    if (!_active || rawHeading == null || !rawHeading.isFinite) {
      return;
    }

    final double normalized = QiblaService.normalizeDegrees(rawHeading);
    final double? current = _unwrappedHeading;
    if (current == null) {
      _unwrappedHeading = normalized;
    } else {
      final double delta = QiblaService.shortestDelta(
        from: QiblaService.normalizeDegrees(current),
        to: normalized,
      );
      _unwrappedHeading = current + (delta * 0.3);
    }
    _heading = QiblaService.normalizeDegrees(_unwrappedHeading!);
    _accuracy = reading.accuracy;
    _sensorState = CompassSensorState.ready;
    _sensorError = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _notify();
  }

  void _markUnavailable(String message) {
    _sensorState = CompassSensorState.unavailable;
    _sensorError = message;
    _heading = null;
    _unwrappedHeading = null;
    _accuracy = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _notify();
  }

  void _handleLocationChanged() {
    final double? previous = _qiblaBearing;
    _updateQiblaBearing();
    if (previous != _qiblaBearing) {
      _notify();
    }
  }

  void _updateQiblaBearing() {
    final double? latitude = _prayerTimesController.location?.latitude;
    final double? longitude = _prayerTimesController.location?.longitude;
    if (latitude == null || longitude == null) {
      _qiblaBearing = null;
      return;
    }
    _qiblaBearing = QiblaService.bearingToKaaba(
      latitude: latitude,
      longitude: longitude,
    );
  }

  void _stopSensor({bool notify = true}) {
    _subscription?.cancel();
    _subscription = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _sensorState = CompassSensorState.idle;
    _heading = null;
    _unwrappedHeading = null;
    _accuracy = null;
    _sensorError = null;
    if (notify) {
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _prayerTimesController.removeListener(_handleLocationChanged);
    _subscription?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }
}
