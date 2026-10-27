import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/prayer.dart';
import '../models/prayer_settings.dart';
import '../models/prayer_times.dart';

class PrayerAlarmService {
  PrayerAlarmService._();

  static final PrayerAlarmService instance = PrayerAlarmService._();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    WidgetsFlutterBinding.ensureInitialized();
    tz.initializeTimeZones();
    try {
      final dynamic tzInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = tzInfo is String ? tzInfo : tzInfo.toString();
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } on Object {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    await Alarm.init();
    _initialized = true;
  }

  Future<void> rescheduleAll({
    required PrayerTimesForDay? times,
    required PrayerAlarmConfig alarmConfig,
  }) async {
    await Alarm.stopAll();
    if (!alarmConfig.enabled || times == null) {
      return;
    }

    final DateTime now = DateTime.now();
    final String dateKey = _dateKey(times.date);

    for (final PrayerId prayer in PrayerId.values) {
      final DateTime? prayerTime = times.timeFor(prayer);
      if (prayerTime == null) {
        continue;
      }
      if (prayerTime.isBefore(now.subtract(const Duration(seconds: 5)))) {
        continue;
      }

      final int id = _alarmId(dateKey, prayer);
      final String assetPath = alarmConfig.useCustomSound
          ? 'assets/sounds/adhan_custom.mp3'
          : 'assets/long_blank.mp3';

      final AlarmSettings settings = AlarmSettings(
        id: id,
        dateTime: prayerTime,
        assetAudioPath: assetPath,
        loopAudio: true,
        vibrate: true,
        volume: 0.8,
        fadeDuration: 3.0,
        notificationSettings: NotificationSettings(
          title: 'Noor - Prayer Time',
          body: '${prayer.label} prayer time',
          stopButton: 'Dismiss',
        ),
      );

      try {
        await Alarm.set(alarmSettings: settings);
      } catch (_) {}
    }
  }

  Future<void> cancelAll() async {
    await Alarm.stopAll();
  }

  Future<bool> ensurePermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        await Permission.notification.request();
      }
      try {
        if (await Permission.scheduleExactAlarm.isDenied) {
          await Permission.scheduleExactAlarm.request();
        }
      } catch (_) {}
      try {
        if (await Permission.ignoreBatteryOptimizations.isDenied) {
          await Permission.ignoreBatteryOptimizations.request();
        }
      } catch (_) {}
      return true;
    }
    if (Platform.isIOS) {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        await Permission.notification.request();
      }
      return true;
    }
    return true;
  }

  Future<void> scheduleTestAlarm() async {
    await ensurePermissions();
    final DateTime testTime = DateTime.now().add(const Duration(seconds: 10));
    final AlarmSettings settings = AlarmSettings(
      id: 999999,
      dateTime: testTime,
      assetAudioPath: 'assets/long_blank.mp3',
      loopAudio: true,
      vibrate: true,
      volume: 0.8,
      fadeDuration: 2.0,
      notificationSettings: const NotificationSettings(
        title: 'Noor - Test Alarm',
        body: 'This is a test of the full-screen prayer alarm',
        stopButton: 'Dismiss',
      ),
    );
    await Alarm.set(alarmSettings: settings);
  }

  int _alarmId(String dateKey, PrayerId prayer) {
    final String key = '|';
    return key.hashCode & 0x7FFFFFFF;
  }

  String _dateKey(DateTime date) {
    final DateTime d = DateTime(date.year, date.month, date.day);
    return '${d.year.toString()}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
  }
}
