import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_tracker/theme/app_theme.dart';
import 'package:prayer_tracker/theme/app_palette.dart';
import 'package:prayer_tracker/widgets/progress_ring.dart';

void main() {
  Widget harness({required int completed, bool disableAnimations = false}) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: Builder(
        builder: (BuildContext context) {
          final AppPalette palette = context.palette;
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: disableAnimations),
            child: Scaffold(
              body: Center(
                child: ProgressRing(
                  completed: completed,
                  total: 5,
                  progressColor: palette.ink,
                  trackColor: palette.line,
                  textColor: palette.ink,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  testWidgets('counts up to the completed total and celebrates completion', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness(completed: 4));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('4'), findsOneWidget);
    expect(find.text('/5'), findsOneWidget);

    await tester.pumpWidget(harness(completed: 5));
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('5'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('reduced motion updates the ring without a pulse', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness(completed: 4, disableAnimations: true));
    await tester.pump();

    await tester.pumpWidget(harness(completed: 5, disableAnimations: true));
    await tester.pump();

    expect(find.text('5'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
