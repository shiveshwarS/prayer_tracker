import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:prayer_tracker/theme/app_theme.dart';
import 'package:prayer_tracker/theme/lottie_assets.dart';
import 'package:prayer_tracker/widgets/noor_lottie.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const List<String> assets = <String>[
    LottieAssets.splashOrbit,
    LottieAssets.prayerCheck,
    LottieAssets.celebrationSparkle,
  ];

  testWidgets('bundled Lottie assets parse into playable compositions', (
    WidgetTester tester,
  ) async {
    for (final String asset in assets) {
      final ByteData data = await rootBundle.load(asset);
      final LottieComposition composition =
          await LottieComposition.fromByteData(data);

      expect(composition.duration, greaterThan(Duration.zero), reason: asset);
      expect(composition.layers, isNotEmpty, reason: asset);
      expect(composition.bounds.width, greaterThan(0), reason: asset);
      expect(composition.bounds.height, greaterThan(0), reason: asset);
    }
  });

  testWidgets('NoorLottie renders its fallback without motion', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (BuildContext context) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(disableAnimations: true),
              child: const Center(
                child: NoorLottie(
                  asset: LottieAssets.splashOrbit,
                  width: 40,
                  height: 40,
                  fallback: SizedBox(
                    key: ValueKey<String>('static-lottie-fallback'),
                    width: 12,
                    height: 12,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('static-lottie-fallback')),
      findsOneWidget,
    );
    expect(tester.hasRunningAnimations, isFalse);
  });
}
