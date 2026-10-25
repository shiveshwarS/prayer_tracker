import '../utils/date_utils.dart';
import 'prayer.dart';

class PrayerHistory {
  PrayerHistory([Map<String, Set<PrayerId>>? days])
    : _days = <String, Set<PrayerId>>{
        for (final MapEntry<String, Set<PrayerId>> entry
            in (days ?? <String, Set<PrayerId>>{}).entries)
          if (entry.value.isNotEmpty) entry.key: Set<PrayerId>.of(entry.value),
      };

  factory PrayerHistory.empty() => PrayerHistory();

  final Map<String, Set<PrayerId>> _days;

  bool get hasAnyPrayers => _days.values.any((Set<PrayerId> day) {
    return day.isNotEmpty;
  });

  Set<PrayerId> completedForDate(DateTime date) {
    return Set<PrayerId>.unmodifiable(
      _days[AppDate.dateKey(date)] ?? const <PrayerId>{},
    );
  }

  int completedCount(DateTime date) => completedForDate(date).length;

  bool isPrayerCompleted(DateTime date, PrayerId prayer) =>
      completedForDate(date).contains(prayer);

  bool isDayComplete(DateTime date) =>
      completedCount(date) == PrayerId.values.length;

  /// Returns the new completion state after toggling.
  bool toggle(DateTime date, PrayerId prayer) {
    final String key = AppDate.dateKey(date);
    final Set<PrayerId> completed = Set<PrayerId>.of(
      _days[key] ?? const <PrayerId>{},
    );
    final bool willBeCompleted = !completed.contains(prayer);
    if (willBeCompleted) {
      completed.add(prayer);
    } else {
      completed.remove(prayer);
    }
    if (completed.isEmpty) {
      _days.remove(key);
    } else {
      _days[key] = completed;
    }
    return willBeCompleted;
  }

  void setCompleted(DateTime date, PrayerId prayer, bool completed) {
    final String key = AppDate.dateKey(date);
    final Set<PrayerId> current = Set<PrayerId>.of(
      _days[key] ?? const <PrayerId>{},
    );
    if (completed) {
      current.add(prayer);
    } else {
      current.remove(prayer);
    }
    if (current.isEmpty) {
      _days.remove(key);
    } else {
      _days[key] = current;
    }
  }

  List<DateTime> get successfulDays {
    final List<DateTime> days = <DateTime>[];
    for (final MapEntry<String, Set<PrayerId>> entry in _days.entries) {
      if (entry.value.length == PrayerId.values.length) {
        final DateTime? date = AppDate.parseDateKey(entry.key);
        if (date != null) {
          days.add(date);
        }
      }
    }
    days.sort((DateTime a, DateTime b) => a.compareTo(b));
    return days;
  }

  int get totalSuccessfulDays => successfulDays.length;

  DateTime? get lastSuccessfulDay {
    final List<DateTime> days = successfulDays;
    return days.isEmpty ? null : days.last;
  }

  /// A day is complete only when all five obligatory prayers are checked.
  int currentStreak({required DateTime today}) {
    final DateTime currentDay = AppDate.dateOnly(today);
    DateTime cursor;
    if (isDayComplete(currentDay)) {
      cursor = currentDay;
    } else {
      final DateTime yesterday = AppDate.addDays(currentDay, -1);
      if (!isDayComplete(yesterday)) {
        return 0;
      }
      cursor = yesterday;
    }

    int streak = 0;
    while (isDayComplete(cursor)) {
      streak++;
      cursor = AppDate.addDays(cursor, -1);
    }
    return streak;
  }

  int get longestStreak {
    final List<DateTime> days = successfulDays;
    if (days.isEmpty) {
      return 0;
    }
    int longest = 1;
    int running = 1;
    for (int index = 1; index < days.length; index++) {
      if (AppDate.daysBetween(days[index - 1], days[index]) == 1) {
        running++;
      } else {
        running = 1;
      }
      if (running > longest) {
        longest = running;
      }
    }
    return longest;
  }

  bool isStreakBroken({required DateTime today}) {
    final DateTime? last = lastSuccessfulDay;
    if (last == null) {
      return false;
    }
    final DateTime currentDay = AppDate.dateOnly(today);
    return !isDayComplete(currentDay) &&
        AppDate.daysBetween(last, currentDay) > 1;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    for (final MapEntry<String, Set<PrayerId>> entry in _days.entries)
      entry.key: entry.value.map((PrayerId prayer) => prayer.name).toList(),
  };

  static PrayerHistory fromJson(Object? value) {
    if (value is! Map) {
      return PrayerHistory.empty();
    }
    final Map<String, Set<PrayerId>> parsed = <String, Set<PrayerId>>{};
    for (final MapEntry<Object?, Object?> entry in value.entries) {
      if (entry.key is! String || entry.value is! List) {
        continue;
      }
      final DateTime? date = AppDate.parseDateKey(entry.key! as String);
      if (date == null) {
        continue;
      }
      final Set<PrayerId> completed = <PrayerId>{};
      for (final Object? rawPrayer in entry.value! as List) {
        if (rawPrayer is String) {
          final PrayerId? prayer = PrayerId.fromStorage(rawPrayer);
          if (prayer != null) {
            completed.add(prayer);
          }
        }
      }
      if (completed.isNotEmpty) {
        parsed[AppDate.dateKey(date)] = completed;
      }
    }
    return PrayerHistory(parsed);
  }

  void clear() => _days.clear();
}
