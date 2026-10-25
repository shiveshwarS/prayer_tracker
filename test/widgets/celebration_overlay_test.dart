import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_tracker/models/prayer.dart';
import 'package:prayer_tracker/models/prayer_moment.dart';
import 'package:prayer_tracker/theme/app_theme.dart';
import 'package:prayer_tracker/widgets/celebration_overlay.dart';

void main() {
  PrayerMoment moment({
    int? milestone,
    int streak = 1,
    bool personalBest = true,
  }) {
    return PrayerMoment(
      sequence: 1,
      prayer: PrayerId.isha,
      date: DateTime(2026, 10, 25),
      completedCount: 5,
      total: 5,
      dayCompleted: true,
      currentStreak: streak,
      milestone: milestone,
      newPersonalBest: personalBest,
    );
  }

  Widget harness(PrayerMoment value, VoidCallback onDismissed) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (BuildContext context) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: Scaffold(
              body: CelebrationOverlay(moment: value, onDismissed: onDismissed),
            ),
          );
        },
      ),
    );
  }

  testWidgets('celebrates a first complete day and dismisses itself', (
    WidgetTester tester,
  ) async {
    bool dismissed = false;
    await tester.pumpWidget(
      harness(moment(milestone: 1), () => dismissed = true),
    );

    expect(find.text('Your first complete day'), findsOneWidget);
    expect(find.text('A MOMENT OF PRAYER'), findsOneWidget);
    expect(
      find.text('Every prayer is complete. A new beginning.'),
      findsOneWidget,
    );
    expect(dismissed, isFalse);

    await tester.pump(const Duration(milliseconds: 1900));
    expect(dismissed, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('shows milestone and personal-best copy', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness(moment(milestone: 7, streak: 7), () {}));

    expect(find.text('7 days of prayer'), findsOneWidget);
    expect(
      find.text('Every prayer is complete. A new personal best of 7 days.'),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
