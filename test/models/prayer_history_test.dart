import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_tracker/models/prayer.dart';
import 'package:prayer_tracker/models/prayer_history.dart';

void main() {
  group('PrayerHistory completion state', () {
    test('toggles prayers without allowing duplicate counts', () {
      final PrayerHistory history = PrayerHistory.empty();
      final DateTime date = DateTime(2026, 10, 25);

      expect(history.completedCount(date), 0);
      expect(history.isDayComplete(date), isFalse);
      expect(history.toggle(date, PrayerId.fajr), isTrue);
      expect(history.toggle(date, PrayerId.fajr), isFalse);
      expect(history.toggle(date, PrayerId.fajr), isTrue);
      expect(history.completedForDate(date), <PrayerId>{PrayerId.fajr});
      expect(history.completedCount(date), 1);
    });

    test('a day is complete only with all five prayers', () {
      final PrayerHistory history = PrayerHistory.empty();
      final DateTime date = DateTime(2026, 10, 25);
      for (final PrayerId prayer in PrayerId.values.take(
        PrayerId.values.length - 1,
      )) {
        history.setCompleted(date, prayer, true);
      }
      expect(history.isDayComplete(date), isFalse);
      history.setCompleted(date, PrayerId.isha, true);
      expect(history.isDayComplete(date), isTrue);
      expect(history.totalSuccessfulDays, 1);
      history.setCompleted(date, PrayerId.isha, false);
      expect(history.isDayComplete(date), isFalse);
      expect(history.totalSuccessfulDays, 0);
    });
  });

  group('PrayerHistory streak logic', () {
    final DateTime today = DateTime(2026, 10, 25);

    void completeDay(PrayerHistory history, DateTime date) {
      for (final PrayerId prayer in PrayerId.values) {
        history.setCompleted(date, prayer, true);
      }
    }

    test('current streak is retained while today is incomplete', () {
      final PrayerHistory history = PrayerHistory.empty();
      completeDay(history, DateTime(2026, 10, 23));
      completeDay(history, DateTime(2026, 10, 24));
      history.setCompleted(today, PrayerId.fajr, true);

      expect(history.currentStreak(today: today), 2);
      expect(history.isStreakBroken(today: today), isFalse);
    });

    test('a missed prior day starts a new streak today', () {
      final PrayerHistory history = PrayerHistory.empty();
      completeDay(history, DateTime(2026, 10, 22));
      completeDay(history, DateTime(2026, 10, 23));
      completeDay(history, today);

      expect(history.currentStreak(today: today), 1);
      expect(history.longestStreak, 2);
      expect(history.isStreakBroken(today: today), isFalse);
    });

    test(
      'incomplete today and last success before yesterday breaks streak',
      () {
        final PrayerHistory history = PrayerHistory.empty();
        completeDay(history, DateTime(2026, 10, 22));
        completeDay(history, DateTime(2026, 10, 23));

        expect(history.currentStreak(today: today), 0);
        expect(history.isStreakBroken(today: today), isTrue);
      },
    );

    test('longest streak spans consecutive successful days only', () {
      final PrayerHistory history = PrayerHistory.empty();
      completeDay(history, DateTime(2026, 10, 1));
      completeDay(history, DateTime(2026, 10, 2));
      completeDay(history, DateTime(2026, 10, 4));
      completeDay(history, DateTime(2026, 10, 5));
      completeDay(history, DateTime(2026, 10, 6));

      expect(history.totalSuccessfulDays, 5);
      expect(history.longestStreak, 3);
      expect(history.lastSuccessfulDay, DateTime(2026, 10, 6));
    });

    test('empty history has no streak and is not broken', () {
      final PrayerHistory history = PrayerHistory.empty();
      expect(history.hasAnyPrayers, isFalse);
      expect(history.currentStreak(today: today), 0);
      expect(history.longestStreak, 0);
      expect(history.isStreakBroken(today: today), isFalse);
    });
  });

  group('PrayerHistory persistence', () {
    test('round-trips valid entries', () {
      final PrayerHistory history = PrayerHistory.empty();
      final DateTime date = DateTime(2026, 10, 25);
      history.setCompleted(date, PrayerId.fajr, true);
      history.setCompleted(date, PrayerId.isha, true);

      final PrayerHistory restored = PrayerHistory.fromJson(history.toJson());
      expect(restored.completedForDate(date), <PrayerId>{
        PrayerId.fajr,
        PrayerId.isha,
      });
      expect(restored.completedForDate(DateTime(2026, 10, 26)), isEmpty);
    });

    test('ignores malformed storage data safely', () {
      final PrayerHistory restored = PrayerHistory.fromJson(<String, Object?>{
        'invalid-date': <String>['fajr'],
        '2026-02-30': <String>['fajr'],
        '2026-10-25': <Object?>['fajr', 'not-a-prayer', 42],
        '2026-10-26': 'not-a-list',
      });
      expect(restored.completedForDate(DateTime(2026, 10, 25)), <PrayerId>{
        PrayerId.fajr,
      });
      expect(restored.hasAnyPrayers, isTrue);
      expect(restored.totalSuccessfulDays, 0);
      expect(PrayerHistory.fromJson('not-a-map').hasAnyPrayers, isFalse);
    });

    test('clear removes all records', () {
      final PrayerHistory history = PrayerHistory.empty();
      history.setCompleted(DateTime(2026, 10, 25), PrayerId.fajr, true);
      expect(history.hasAnyPrayers, isTrue);
      history.clear();
      expect(history.hasAnyPrayers, isFalse);
      expect(history.toJson(), isEmpty);
    });
  });
}
