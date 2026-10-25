import 'dart:math' as math;

abstract final class QiblaService {
  static const double kaabaLatitude = 21.422487;
  static const double kaabaLongitude = 39.826206;

  static double normalizeDegrees(double value) {
    final double normalized = value % 360;
    return normalized < 0 ? normalized + 360 : normalized;
  }

  /// Spherical initial bearing from a coordinate to the Kaaba.
  static double bearingToKaaba({
    required double latitude,
    required double longitude,
  }) {
    final double lat1 = _radians(latitude);
    final double lat2 = _radians(kaabaLatitude);
    final double deltaLongitude = _radians(kaabaLongitude - longitude);

    final double y = math.sin(deltaLongitude) * math.cos(lat2);
    final double x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLongitude);
    final double bearing = math.atan2(y, x) * 180 / math.pi;
    return normalizeDegrees(bearing);
  }

  /// The clockwise angle of the Qibla relative to the top of the device.
  static double relativeAngle({
    required double qiblaBearing,
    required double deviceHeading,
  }) {
    return normalizeDegrees(qiblaBearing - deviceHeading);
  }

  static double shortestDelta({required double from, required double to}) {
    return ((to - from + 540) % 360) - 180;
  }

  static bool isAligned({
    required double qiblaBearing,
    required double deviceHeading,
    double tolerance = 4,
  }) {
    final double relative = relativeAngle(
      qiblaBearing: qiblaBearing,
      deviceHeading: deviceHeading,
    );
    final double distance = math.min(relative, 360 - relative);
    return distance <= tolerance;
  }

  static double _radians(double degrees) => degrees * math.pi / 180;
}
