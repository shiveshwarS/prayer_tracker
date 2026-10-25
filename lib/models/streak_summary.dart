import '../utils/date_utils.dart';
import 'prayer_history.dart';

class StreakSummary {
  const StreakSummary({
    required this.date,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalSuccessfulDays,
    required this.todayCompleted,
    required this.todayComplete,
    required this.hasAnyPrayers,
    required this.lastSuccessfulDay,
    required this.isStreakBroken,
  });

  factory StreakSummary.fromHistory(
    PrayerHistory history, {
    required DateTime today,
  }) {
    final DateTime day = AppDate.dateOnly(today);
    return StreakSummary(
      date: day,
      currentStreak: history.currentStreak(today: day),
      longestStreak: history.longestStreak,
      totalSuccessfulDays: history.totalSuccessfulDays,
      todayCompleted: history.completedCount(day),
      todayComplete: history.isDayComplete(day),
      hasAnyPrayers: history.hasAnyPrayers,
      lastSuccessfulDay: history.lastSuccessfulDay,
      isStreakBroken: history.isStreakBroken(today: day),
    );
  }

  final DateTime date;
  final int currentStreak;
  final int longestStreak;
  final int totalSuccessfulDays;
  final int todayCompleted;
  final bool todayComplete;
  final bool hasAnyPrayers;
  final DateTime? lastSuccessfulDay;
  final bool isStreakBroken;

  int get todayTotal => 5;

  double get todayProgress => todayCompleted / todayTotal;
}
