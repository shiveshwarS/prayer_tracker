import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_tracker/services/qibla_service.dart';

void main() {
  group('QiblaService bearings', () {
    test('normalizes degrees into 0-360', () {
      expect(QiblaService.normalizeDegrees(0), 0);
      expect(QiblaService.normalizeDegrees(360), 0);
      expect(QiblaService.normalizeDegrees(-10), 350);
      expect(QiblaService.normalizeDegrees(725), 5);
    });

    test('calculates well-known Qibla bearings', () {
      expect(
        QiblaService.bearingToKaaba(latitude: 51.5074, longitude: -0.1278),
        closeTo(118.99, 0.5),
        reason: 'London',
      );
      expect(
        QiblaService.bearingToKaaba(latitude: 40.7128, longitude: -74.0060),
        closeTo(58.48, 0.5),
        reason: 'New York',
      );
      expect(
        QiblaService.bearingToKaaba(latitude: -6.2088, longitude: 106.8456),
        closeTo(295.15, 0.5),
        reason: 'Jakarta',
      );
    });

    test('relative angle rotates with device heading', () {
      expect(
        QiblaService.relativeAngle(qiblaBearing: 120, deviceHeading: 100),
        20,
      );
      expect(
        QiblaService.relativeAngle(qiblaBearing: 10, deviceHeading: 350),
        20,
      );
      expect(
        QiblaService.relativeAngle(qiblaBearing: 350, deviceHeading: 10),
        340,
      );
    });

    test('shortest delta wraps across north', () {
      expect(QiblaService.shortestDelta(from: 350, to: 10), 20);
      expect(QiblaService.shortestDelta(from: 10, to: 350), -20);
      expect(QiblaService.shortestDelta(from: 0, to: 180).abs(), 180);
      expect(QiblaService.shortestDelta(from: 90, to: 90), 0);
    });

    test('alignment tolerance handles both sides of north', () {
      expect(
        QiblaService.isAligned(qiblaBearing: 2, deviceHeading: 359),
        isTrue,
      );
      expect(QiblaService.isAligned(qiblaBearing: 4, deviceHeading: 0), isTrue);
      expect(
        QiblaService.isAligned(qiblaBearing: 20, deviceHeading: 0),
        isFalse,
      );
      expect(
        QiblaService.isAligned(
          qiblaBearing: 20,
          deviceHeading: 0,
          tolerance: 20,
        ),
        isTrue,
      );
    });
  });
}
