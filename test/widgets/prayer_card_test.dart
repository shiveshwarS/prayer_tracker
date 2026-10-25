import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_tracker/models/prayer.dart';
import 'package:prayer_tracker/theme/app_theme.dart';
import 'package:prayer_tracker/widgets/prayer_card.dart';

void main() {
  Widget harness({
    required bool completed,
    required VoidCallback onToggle,
    bool disableAnimations = false,
  }) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (BuildContext context) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: disableAnimations),
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 360,
                  child: PrayerCard(
                    prayer: PrayerId.fajr,
                    time: DateTime(2026, 10, 25, 5, 12),
                    completed: completed,
                    onToggle: onToggle,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  testWidgets('toggles and plays the completion pulse', (
    WidgetTester tester,
  ) async {
    bool toggled = false;
    await tester.pumpWidget(
      harness(completed: false, onToggle: () => toggled = true),
    );

    expect(find.text('Not completed'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('prayer-toggle-fajr')));
    expect(toggled, isTrue);

    await tester.pumpWidget(harness(completed: true, onToggle: () {}));
    await tester.pump();

    expect(find.text('Completed'), findsOneWidget);
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('reduced motion skips the completion pulse', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      harness(completed: false, onToggle: () {}, disableAnimations: true),
    );

    await tester.pumpWidget(
      harness(completed: true, onToggle: () {}, disableAnimations: true),
    );
    await tester.pump();

    expect(find.text('Completed'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
