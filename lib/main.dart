import 'dart:async';

import 'package:flutter/widgets.dart';

import 'app.dart';
import 'services/prayer_alarm_service.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await PrayerAlarmService.initialize();
    runApp(const NoorApp());
  }, (Object error, StackTrace stackTrace) {
    // Ignore startup errors
  });
}
