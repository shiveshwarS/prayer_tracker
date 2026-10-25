import 'package:flutter_compass/flutter_compass.dart';

class CompassReading {
  const CompassReading({required this.heading, this.accuracy});

  final double? heading;
  final double? accuracy;
}

abstract interface class CompassHeadingSource {
  Stream<CompassReading> get readings;
}

class FlutterCompassHeadingSource implements CompassHeadingSource {
  const FlutterCompassHeadingSource();

  @override
  Stream<CompassReading> get readings {
    final Stream<CompassEvent>? events = FlutterCompass.events;
    if (events == null) {
      return const Stream<CompassReading>.empty();
    }
    return events.map(
      (CompassEvent event) =>
          CompassReading(heading: event.heading, accuracy: event.accuracy),
    );
  }
}
