import 'prayer.dart';

class PrayerTimesForDay {
  const PrayerTimesForDay({
    required this.date,
    required this.times,
    required this.fajrTomorrow,
  });

  final DateTime date;
  final Map<PrayerId, DateTime> times;
  final DateTime fajrTomorrow;

  DateTime? timeFor(PrayerId prayer) => times[prayer];

  bool get isComplete =>
      PrayerId.values.every((PrayerId prayer) => times[prayer] != null);
}

class NextPrayerInfo {
  const NextPrayerInfo({
    required this.prayer,
    required this.time,
    required this.isTomorrow,
  });

  final PrayerId prayer;
  final DateTime time;
  final bool isTomorrow;
}
