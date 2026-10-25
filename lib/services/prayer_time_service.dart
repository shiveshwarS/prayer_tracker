import 'package:adhan_dart/adhan_dart.dart' as adhan;

import '../models/prayer.dart';
import '../models/prayer_settings.dart';
import '../models/prayer_times.dart';
import '../models/saved_location.dart';
import '../utils/date_utils.dart';

class PrayerTimeService {
  const PrayerTimeService();

  PrayerTimesForDay? calculateForDay({
    required SavedLocation location,
    required DateTime date,
    required PrayerCalculationMethod method,
    required AsrMadhab madhab,
  }) {
    if (!location.isValid) {
      return null;
    }

    try {
      final DateTime dateOnly = DateTime(date.year, date.month, date.day);
      final adhan.PrayerTimes times = _buildPrayerTimes(
        location: location,
        date: dateOnly,
        method: method,
        madhab: madhab,
      );

      final Map<PrayerId, DateTime> localTimes = <PrayerId, DateTime>{
        PrayerId.fajr: times.fajr.toLocal(),
        PrayerId.dhuhr: times.dhuhr.toLocal(),
        PrayerId.asr: times.asr.toLocal(),
        PrayerId.maghrib: times.maghrib.toLocal(),
        PrayerId.isha: times.isha.toLocal(),
      };
      final DateTime isha = localTimes[PrayerId.isha]!;
      final adhan.PrayerTimes tomorrowTimes = _buildPrayerTimes(
        location: location,
        date: DateTime(dateOnly.year, dateOnly.month, dateOnly.day + 1),
        method: method,
        madhab: madhab,
      );
      DateTime fajrTomorrow = tomorrowTimes.fajr.toLocal();
      if (!fajrTomorrow.isAfter(isha)) {
        fajrTomorrow = isha.add(const Duration(hours: 8));
      }

      if (!_hasValidOrder(localTimes)) {
        return null;
      }

      return PrayerTimesForDay(
        date: AppDate.dateOnly(date),
        times: localTimes,
        fajrTomorrow: fajrTomorrow,
      );
    } on Object {
      return null;
    }
  }

  adhan.PrayerTimes _buildPrayerTimes({
    required SavedLocation location,
    required DateTime date,
    required PrayerCalculationMethod method,
    required AsrMadhab madhab,
  }) {
    final adhan.Coordinates coordinates = adhan.Coordinates(
      location.latitude,
      location.longitude,
    );
    final adhan.CalculationParameters parameters =
        _parametersFor(method)
          ..madhab =
              madhab == AsrMadhab.hanafi
                  ? adhan.Madhab.hanafi
                  : adhan.Madhab.shafi
          ..highLatitudeRule = adhan.HighLatitudeRule.recommended(coordinates);

    return adhan.PrayerTimes(
      date: date,
      coordinates: coordinates,
      calculationParameters: parameters,
      precision: true,
    );
  }

  NextPrayerInfo? nextPrayer({
    required PrayerTimesForDay times,
    required DateTime now,
  }) {
    for (final PrayerId prayer in PrayerId.values) {
      final DateTime? time = times.timeFor(prayer);
      if (time != null && time.isAfter(now)) {
        return NextPrayerInfo(prayer: prayer, time: time, isTomorrow: false);
      }
    }
    return NextPrayerInfo(
      prayer: PrayerId.fajr,
      time: times.fajrTomorrow,
      isTomorrow: true,
    );
  }

  bool _hasValidOrder(Map<PrayerId, DateTime> times) {
    final List<DateTime> ordered =
        PrayerId.values
            .map((PrayerId prayer) => times[prayer])
            .whereType<DateTime>()
            .toList();
    if (ordered.length != PrayerId.values.length) {
      return false;
    }
    for (int index = 1; index < ordered.length; index++) {
      if (!ordered[index].isAfter(ordered[index - 1])) {
        return false;
      }
    }
    return true;
  }

  adhan.CalculationParameters _parametersFor(PrayerCalculationMethod method) {
    switch (method) {
      case PrayerCalculationMethod.muslimWorldLeague:
        return adhan.CalculationMethodParameters.muslimWorldLeague();
      case PrayerCalculationMethod.karachi:
        return adhan.CalculationMethodParameters.karachi();
      case PrayerCalculationMethod.ummAlQura:
        return adhan.CalculationMethodParameters.ummAlQura();
      case PrayerCalculationMethod.egyptian:
        return adhan.CalculationMethodParameters.egyptian();
      case PrayerCalculationMethod.dubai:
        return adhan.CalculationMethodParameters.dubai();
      case PrayerCalculationMethod.northAmerica:
        return adhan.CalculationMethodParameters.northAmerica();
      case PrayerCalculationMethod.moonsightingCommittee:
        return adhan.CalculationMethodParameters.moonsightingCommittee();
      case PrayerCalculationMethod.singapore:
        return adhan.CalculationMethodParameters.singapore();
      case PrayerCalculationMethod.turkiye:
        return adhan.CalculationMethodParameters.turkiye();
    }
  }
}
