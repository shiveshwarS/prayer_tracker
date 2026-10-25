import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_tracker/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('signs up, tracks Fajr, and disposes cleanly', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const NoorApp());
    await tester.pump();
    for (int index = 0; index < 10; index++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (find
          .byKey(const ValueKey<String>('signup-view'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
    }

    expect(find.byKey(const ValueKey<String>('signup-view')), findsOneWidget);
    expect(find.text('A quiet place\nfor prayer.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey<String>('signup-name-field')),
      'Amina',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('signup-phone-field')),
      '07700900123',
    );
    await tester.tap(find.textContaining('I understand my profile'));
    await tester.pump();

    final Finder startButton = find.text('Begin with Noor');
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Amina'), findsOneWidget);
    expect(find.text('Assalamu alaikum,'), findsOneWidget);

    final Finder fajrToggle = find.byKey(
      const ValueKey<String>('prayer-toggle-fajr'),
    );
    await tester.ensureVisible(fajrToggle);
    await tester.pump();
    await tester.tap(fajrToggle);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Completed'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
