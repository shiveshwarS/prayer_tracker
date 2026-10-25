import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_tracker/utils/calendar_utils.dart';
import 'package:prayer_tracker/utils/date_utils.dart';

void main() {
  group('AppDate', () {
    test('normalizes dates and adds calendar days', () {
      final DateTime withTime = DateTime(2026, 10, 25, 18, 42, 11);
      expect(AppDate.dateOnly(withTime), DateTime(2026, 10, 25));
      expect(AppDate.addDays(withTime, 1), DateTime(2026, 10, 26));
      expect(AppDate.addDays(DateTime(2024, 2, 28), 1), DateTime(2024, 2, 29));
      expect(AppDate.addDays(DateTime(2025, 12, 31), 1), DateTime(2026, 1, 1));
    });

    test('date keys round-trip and reject malformed dates', () {
      final DateTime date = DateTime(2024, 2, 29);
      expect(AppDate.dateKey(date), '2024-02-29');
      expect(AppDate.parseDateKey('2024-02-29'), date);
      expect(AppDate.parseDateKey('2025-02-29'), isNull);
      expect(AppDate.parseDateKey('2024-13-01'), isNull);
      expect(AppDate.parseDateKey('not-a-date'), isNull);
      expect(AppDate.parseDateKey('2024-2-9'), DateTime(2024, 2, 9));
    });

    test('daysBetween uses calendar days across DST boundaries', () {
      expect(
        AppDate.daysBetween(DateTime(2024, 3, 9), DateTime(2024, 3, 11)),
        2,
      );
      expect(
        AppDate.daysBetween(DateTime(2024, 10, 26), DateTime(2024, 10, 28)),
        2,
      );
    });

    test('formats times and coordinates consistently', () {
      expect(AppDate.formatTime(DateTime(2026, 1, 1, 0, 5)), '12:05 AM');
      expect(AppDate.formatTime(DateTime(2026, 1, 1, 12, 0)), '12:00 PM');
      expect(AppDate.formatTime(DateTime(2026, 1, 1, 23, 59)), '11:59 PM');
      expect(AppDate.formatCoordinate(21.4225), '21.4225°N');
      expect(AppDate.formatCoordinate(-6.2088), '6.2088°S');
      expect(AppDate.formatLongitude(39.8262), '39.8262°E');
      expect(AppDate.formatLongitude(-0.1278), '0.1278°W');
      expect(AppDate.formatDays(1), '1 day');
      expect(AppDate.formatDays(5), '5 days');
    });
  });

  group('MonthGrid', () {
    test('aligns a leap-year February from Monday', () {
      final MonthGrid grid = MonthGrid.forMonth(DateTime(2024, 2, 12));
      expect(grid.dayCount, 29);
      expect(grid.leadingBlanks, 3);
      expect(grid.rowCount, 5);
      expect(grid.cells.length, 35);
      expect(grid.cells[3].date, DateTime(2024, 2, 1));
      expect(grid.cells[31].date, DateTime(2024, 2, 29));
      expect(grid.cells.first.date, isNull);
      expect(grid.cells.last.date, isNull);
      expect(MonthGrid.isLeapYear(2024), isTrue);
      expect(MonthGrid.isLeapYear(1900), isFalse);
      expect(MonthGrid.isLeapYear(2000), isTrue);
    });

    test('handles six-week months and month navigation', () {
      final MonthGrid grid = MonthGrid.forMonth(DateTime(2024, 9, 15));
      expect(grid.leadingBlanks, 6);
      expect(grid.rowCount, 6);
      expect(grid.cells.length, 42);
      expect(grid.cells[6].date, DateTime(2024, 9, 1));
      expect(grid.previousMonth, DateTime(2024, 8));
      expect(grid.nextMonth, DateTime(2024, 10));
      expect(grid.isSameMonth(DateTime(2024, 9, 30)), isTrue);
      expect(grid.isCurrentMonth(DateTime(2024, 9, 1)), isTrue);
      expect(grid.isCurrentMonth(DateTime(2024, 10, 1)), isFalse);
    });

    test('every month starts on the correct weekday column', () {
      for (int year = 2020; year <= 2028; year++) {
        for (int month = 1; month <= 12; month++) {
          final MonthGrid grid = MonthGrid.forMonth(DateTime(year, month));
          final int expected = (DateTime(year, month).weekday - 1) % 7;
          expect(
            grid.leadingBlanks,
            expected,
            reason: '$year-$month leading alignment',
          );
          expect(grid.cells[grid.leadingBlanks].date, DateTime(year, month, 1));
        }
      }
    });
  });
}
