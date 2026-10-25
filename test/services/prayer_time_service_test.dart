import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_tracker/models/prayer.dart';
import 'package:prayer_tracker/models/prayer_settings.dart';
import 'package:prayer_tracker/models/prayer_times.dart';
import 'package:prayer_tracker/models/saved_location.dart';
import 'package:prayer_tracker/services/prayer_time_service.dart';

void main() {
  const PrayerTimeService service = PrayerTimeService();
  const SavedLocation london = SavedLocation(
    latitude: 51.5074,
    longitude: -0.1278,
    label: 'London',
    source: LocationSource.manual,
  );
  const SavedLocation makkah = SavedLocation(
    latitude: 21.4225,
    longitude: 39.8262,
    label: 'Makkah',
    source: LocationSource.manual,
  );
  final DateTime date = DateTime(2026, 6, 21);

  group('PrayerTimeService.calculateForDay', () {
    test('returns five ordered prayer times', () {
      final PrayerTimesForDay? times = service.calculateForDay(
        location: london,
        date: date,
        method: PrayerCalculationMethod.muslimWorldLeague,
        madhab: AsrMadhab.shafi,
      );

      expect(times, isNotNull);
      expect(times!.isComplete, isTrue);
      expect(times.date, DateTime(2026, 6, 21));
      final List<DateTime> ordered =
          PrayerId.values
              .map((PrayerId prayer) => times.timeFor(prayer)!)
              .toList();
      for (int index = 1; index < ordered.length; index++) {
        expect(ordered[index].isAfter(ordered[index - 1]), isTrue);
      }
      expect(times.fajrTomorrow.isAfter(times.timeFor(PrayerId.isha)!), isTrue);
    });

    test('Hanafi Asr is later than Shafi Asr', () {
      final PrayerTimesForDay shafi =
          service.calculateForDay(
            location: london,
            date: date,
            method: PrayerCalculationMethod.muslimWorldLeague,
            madhab: AsrMadhab.shafi,
          )!;
      final PrayerTimesForDay hanafi =
          service.calculateForDay(
            location: london,
            date: date,
            method: PrayerCalculationMethod.muslimWorldLeague,
            madhab: AsrMadhab.hanafi,
          )!;
      expect(
        hanafi.timeFor(PrayerId.asr)!.isAfter(shafi.timeFor(PrayerId.asr)!),
        isTrue,
      );
      expect(shafi.timeFor(PrayerId.fajr), hanafi.timeFor(PrayerId.fajr));
    });

    test('different methods produce different Fajr times', () {
      final PrayerTimesForDay mwl =
          service.calculateForDay(
            location: makkah,
            date: date,
            method: PrayerCalculationMethod.muslimWorldLeague,
            madhab: AsrMadhab.shafi,
          )!;
      final PrayerTimesForDay isna =
          service.calculateForDay(
            location: makkah,
            date: date,
            method: PrayerCalculationMethod.northAmerica,
            madhab: AsrMadhab.shafi,
          )!;
      expect(mwl.timeFor(PrayerId.fajr), isNot(isna.timeFor(PrayerId.fajr)));
    });

    test('rejects invalid coordinates', () {
      const SavedLocation invalid = SavedLocation(
        latitude: 100,
        longitude: 0,
        label: 'Invalid',
        source: LocationSource.manual,
      );
      expect(
        service.calculateForDay(
          location: invalid,
          date: date,
          method: PrayerCalculationMethod.muslimWorldLeague,
          madhab: AsrMadhab.shafi,
        ),
        isNull,
      );
    });
  });

  group('PrayerTimeService.nextPrayer', () {
    final PrayerTimesForDay times =
        service.calculateForDay(
          location: london,
          date: date,
          method: PrayerCalculationMethod.muslimWorldLeague,
          madhab: AsrMadhab.shafi,
        )!;

    test('returns the next prayer today', () {
      final NextPrayerInfo next =
          service.nextPrayer(
            times: times,
            now: times
                .timeFor(PrayerId.fajr)!
                .subtract(const Duration(minutes: 1)),
          )!;
      expect(next.prayer, PrayerId.fajr);
      expect(next.isTomorrow, isFalse);

      final NextPrayerInfo afterFajr =
          service.nextPrayer(
            times: times,
            now: times.timeFor(PrayerId.fajr)!.add(const Duration(minutes: 1)),
          )!;
      expect(afterFajr.prayer, PrayerId.dhuhr);
    });

    test('returns tomorrow Fajr after Isha', () {
      final NextPrayerInfo next =
          service.nextPrayer(
            times: times,
            now: times.timeFor(PrayerId.isha)!.add(const Duration(minutes: 1)),
          )!;
      expect(next.prayer, PrayerId.fajr);
      expect(next.isTomorrow, isTrue);
      expect(next.time, times.fajrTomorrow);
    });
  });
}
