import 'package:flutter/material.dart';

import '../models/prayer.dart';
import '../models/prayer_times.dart';
import '../theme/app_palette.dart';

enum DayPhase { dawn, day, dusk, night }

extension DayPhaseStyle on DayPhase {
  Color accent(AppPalette palette) {
    switch (this) {
      case DayPhase.dawn:
        return palette.haloWarm;
      case DayPhase.day:
        return palette.haloCool;
      case DayPhase.dusk:
        return palette.gold;
      case DayPhase.night:
        return palette.haloCool;
    }
  }

  Color secondary(AppPalette palette) {
    switch (this) {
      case DayPhase.dawn:
        return palette.gold;
      case DayPhase.day:
        return palette.haloWarm;
      case DayPhase.dusk:
        return palette.haloWarm;
      case DayPhase.night:
        return palette.gold;
    }
  }
}

DayPhase dayPhaseFor({required DateTime now, PrayerTimesForDay? times}) {
  final DateTime? fajr = times?.timeFor(PrayerId.fajr);
  final DateTime? dhuhr = times?.timeFor(PrayerId.dhuhr);
  final DateTime? asr = times?.timeFor(PrayerId.asr);
  final DateTime? maghrib = times?.timeFor(PrayerId.maghrib);
  final DateTime? isha = times?.timeFor(PrayerId.isha);

  if (fajr != null &&
      dhuhr != null &&
      asr != null &&
      maghrib != null &&
      isha != null) {
    if (now.isBefore(fajr) || !now.isBefore(isha)) {
      return DayPhase.night;
    }
    if (now.isBefore(dhuhr)) {
      return DayPhase.dawn;
    }
    if (now.isBefore(asr)) {
      return DayPhase.day;
    }
    if (now.isBefore(maghrib)) {
      return DayPhase.dusk;
    }
    return DayPhase.dusk;
  }

  final int hour = now.hour;
  if (hour >= 5 && hour < 8) {
    return DayPhase.dawn;
  }
  if (hour >= 8 && hour < 17) {
    return DayPhase.day;
  }
  if (hour >= 17 && hour < 20) {
    return DayPhase.dusk;
  }
  return DayPhase.night;
}
