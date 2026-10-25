import 'prayer.dart';

class PrayerMoment {
  const PrayerMoment({
    required this.sequence,
    required this.prayer,
    required this.date,
    required this.completedCount,
    required this.total,
    required this.dayCompleted,
    required this.currentStreak,
    required this.milestone,
    required this.newPersonalBest,
  });

  static const Set<int> milestones = <int>{1, 3, 7, 14, 30};

  final int sequence;
  final PrayerId prayer;
  final DateTime date;
  final int completedCount;
  final int total;
  final bool dayCompleted;
  final int currentStreak;
  final int? milestone;
  final bool newPersonalBest;

  bool get hasCelebration => dayCompleted || milestone != null;
}
