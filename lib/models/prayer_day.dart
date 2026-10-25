import 'package:flutter/foundation.dart';

import '../utils/date_utils.dart';
import 'prayer.dart';

@immutable
class PrayerDay {
  PrayerDay({required DateTime date, Set<PrayerId>? completed})
    : date = AppDate.dateOnly(date),
      completed = Set<PrayerId>.unmodifiable(completed ?? <PrayerId>{});

  final DateTime date;
  final Set<PrayerId> completed;

  int get completedCount => completed.length;

  bool get isSuccessful => completed.length == PrayerId.values.length;

  bool isCompleted(PrayerId prayer) => completed.contains(prayer);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'date': AppDate.dateKey(date),
    'prayers': completed.map((PrayerId prayer) => prayer.name).toList(),
  };

  static PrayerDay? fromJson(Object? value) {
    if (value is! Map) {
      return null;
    }
    final Object? rawDate = value['date'];
    final Object? rawPrayers = value['prayers'];
    if (rawDate is! String || rawPrayers is! List) {
      return null;
    }
    final DateTime? date = AppDate.parseDateKey(rawDate);
    if (date == null) {
      return null;
    }
    final Set<PrayerId> completed = <PrayerId>{};
    for (final Object? rawPrayer in rawPrayers) {
      if (rawPrayer is String) {
        final PrayerId? prayer = PrayerId.fromStorage(rawPrayer);
        if (prayer != null) {
          completed.add(prayer);
        }
      }
    }
    return PrayerDay(date: date, completed: completed);
  }
}
