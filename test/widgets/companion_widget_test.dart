import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_tracker/models/streak_summary.dart';
import 'package:prayer_tracker/theme/app_theme.dart';
import 'package:prayer_tracker/widgets/companion_widget.dart';

void main() {
  StreakSummary summary({
    int completed = 0,
    int streak = 0,
    bool broken = false,
  }) {
    final DateTime date = DateTime(2026, 10, 25);
    return StreakSummary(
      date: date,
      currentStreak: streak,
      longestStreak: streak,
      totalSuccessfulDays: streak,
      todayCompleted: completed,
      todayComplete: completed >= 5,
      hasAnyPrayers: completed > 0,
      lastSuccessfulDay: completed >= 5 ? date : null,
      isStreakBroken: broken,
    );
  }

  Widget harness({
    required StreakSummary summary,
    bool disableAnimations = false,
    bool tickerEnabled = true,
  }) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (BuildContext context) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: disableAnimations),
            child: TickerMode(
              enabled: tickerEnabled,
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 340,
                    child: CompanionWidget(summary: summary),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<double> motionOf(WidgetTester tester) {
    final Transform motion = tester.widget<Transform>(
      find.byKey(const ValueKey<String>('companion-motion')),
    );
    return motion.transform.storage.toList();
  }

  testWidgets('companion idles and moves continuously', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness(summary: summary()));
    await tester.pump();

    expect(tester.hasRunningAnimations, isTrue);
    final List<double> initial = motionOf(tester);

    await tester.pump(const Duration(milliseconds: 700));
    final List<double> moved = motionOf(tester);

    expect(moved[13], isNot(equals(initial[13])));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('reduced motion leaves the companion still', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      harness(summary: summary(), disableAnimations: true),
    );
    await tester.pump();

    expect(tester.hasRunningAnimations, isFalse);
    final List<double> initial = motionOf(tester);

    await tester.pump(const Duration(milliseconds: 700));
    expect(motionOf(tester)[13], equals(initial[13]));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('offstage companion does not animate', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness(summary: summary(), tickerEnabled: false));
    await tester.pump();

    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('mood changes update the companion message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness(summary: summary()));
    await tester.pump();
    expect(find.text('A gentle beginning'), findsOneWidget);

    await tester.pumpWidget(harness(summary: summary(completed: 1, streak: 0)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));

    expect(find.text('One prayer at a time'), findsOneWidget);
    expect(find.text('A gentle beginning'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
