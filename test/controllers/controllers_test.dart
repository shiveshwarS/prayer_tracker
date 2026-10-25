import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_tracker/controllers/auth_controller.dart';
import 'package:prayer_tracker/controllers/prayer_controller.dart';
import 'package:prayer_tracker/controllers/prayer_times_controller.dart';
import 'package:prayer_tracker/controllers/theme_controller.dart';
import 'package:prayer_tracker/models/prayer.dart';
import 'package:prayer_tracker/models/prayer_settings.dart';
import 'package:prayer_tracker/models/saved_location.dart';
import 'package:prayer_tracker/services/local_storage_service.dart';
import 'package:prayer_tracker/services/location_service.dart';
import 'package:prayer_tracker/services/prayer_time_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<LocalStorageService> createStorage() async {
    return LocalStorageService(await SharedPreferences.getInstance());
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('AuthController', () {
    test('creates and restores a local profile', () async {
      final LocalStorageService storage = await createStorage();
      final AuthController auth = AuthController(storage: storage);
      await auth.initialize();
      expect(auth.isSignedIn, isFalse);

      final bool created = await auth.signUp(
        name: '  Amina Rahman ',
        phone: ' +44 7700 900123 ',
      );
      expect(created, isTrue);
      expect(auth.user?.name, 'Amina Rahman');
      expect(auth.user?.firstName, 'Amina');
      expect(auth.user?.initial, 'A');
      expect(auth.errorMessage, isNull);

      final AuthController restored = AuthController(storage: storage);
      await restored.initialize();
      expect(restored.isSignedIn, isTrue);
      expect(restored.user?.phone, '+44 7700 900123');
    });

    test('rejects invalid profile details', () async {
      final LocalStorageService storage = await createStorage();
      final AuthController auth = AuthController(storage: storage);
      await auth.initialize();

      expect(await auth.signUp(name: '', phone: '123'), isFalse);
      expect(auth.user, isNull);
      expect(auth.errorMessage, isNotNull);

      expect(await auth.signUp(name: 'A', phone: '123456'), isFalse);
      expect(auth.errorMessage, contains('2 characters'));
    });

    test('updates an existing profile and clears local user state', () async {
      final LocalStorageService storage = await createStorage();
      final AuthController auth = AuthController(storage: storage);
      await auth.initialize();
      await auth.signUp(name: 'Amina', phone: '123456');

      final bool updated = await auth.updateProfile(
        name: 'Amina Yusuf',
        phone: '654321',
      );
      expect(updated, isTrue);
      expect(auth.user?.name, 'Amina Yusuf');

      auth.clearLocalUser();
      expect(auth.isSignedIn, isFalse);
    });
  });

  group('PrayerController', () {
    test('persists completions and restores summary', () async {
      final LocalStorageService storage = await createStorage();
      final DateTime now = DateTime(2026, 10, 25, 20);
      final PrayerController controller = PrayerController(
        storage: storage,
        clock: () => now,
      );
      await controller.initialize();
      expect(controller.todayCompleted, 0);

      for (final PrayerId prayer in PrayerId.values) {
        expect(controller.togglePrayer(prayer), isTrue);
      }
      expect(controller.isTodayComplete, isTrue);
      expect(controller.currentStreak, 1);
      expect(controller.summary.todayProgress, 1);
      await controller.flush();

      final PrayerController restored = PrayerController(
        storage: storage,
        clock: () => now,
      );
      await restored.initialize();
      expect(restored.todayCompleted, PrayerId.values.length);
      expect(restored.isTodayComplete, isTrue);
      expect(restored.currentStreak, 1);
    });

    test('rolls over to a fresh day while retaining the streak', () async {
      DateTime now = DateTime(2026, 10, 25, 20);
      final LocalStorageService storage = await createStorage();
      final PrayerController controller = PrayerController(
        storage: storage,
        clock: () => now,
      );
      await controller.initialize();
      for (final PrayerId prayer in PrayerId.values) {
        controller.togglePrayer(prayer);
      }
      await controller.flush();

      now = DateTime(2026, 10, 26, 6);
      controller.refreshToday();
      expect(controller.todayCompleted, 0);
      expect(controller.currentStreak, 1);

      controller.togglePrayer(PrayerId.fajr);
      expect(controller.todayCompleted, 1);
      expect(controller.currentStreak, 1);
    });
  });

  group('PrayerTimesController', () {
    test(
      'calculates times for a manual location and persists settings',
      () async {
        final LocalStorageService storage = await createStorage();
        final PrayerTimesController controller = PrayerTimesController(
          prayerTimeService: const PrayerTimeService(),
          locationService: const LocationService(),
          storage: storage,
          clock: () => DateTime(2026, 6, 21, 12),
        );
        await controller.initialize();
        expect(controller.hasLocation, isFalse);
        expect(controller.hasTimes, isFalse);

        await controller.setManualLocation(
          const SavedLocation(
            latitude: 51.5074,
            longitude: -0.1278,
            label: 'London',
            source: LocationSource.manual,
          ),
        );
        expect(controller.hasLocation, isTrue);
        expect(controller.hasTimes, isTrue);
        expect(controller.timeFor(PrayerId.fajr), isNotNull);
        expect(controller.nextPrayer, isNotNull);

        await controller.setMethod(PrayerCalculationMethod.northAmerica);
        await controller.setMadhab(AsrMadhab.hanafi);
        expect(controller.method, PrayerCalculationMethod.northAmerica);
        expect(controller.madhab, AsrMadhab.hanafi);

        final PrayerTimesController restored = PrayerTimesController(
          prayerTimeService: const PrayerTimeService(),
          locationService: const LocationService(),
          storage: storage,
          clock: () => DateTime(2026, 6, 21, 12),
        );
        await restored.initialize();
        expect(restored.location?.label, 'London');
        expect(restored.method, PrayerCalculationMethod.northAmerica);
        expect(restored.madhab, AsrMadhab.hanafi);
        expect(restored.hasTimes, isTrue);
      },
    );

    test('clearing location removes calculated times', () async {
      final LocalStorageService storage = await createStorage();
      final PrayerTimesController controller = PrayerTimesController(
        prayerTimeService: const PrayerTimeService(),
        locationService: const LocationService(),
        storage: storage,
      );
      await controller.initialize();
      await controller.setManualLocation(
        const SavedLocation(
          latitude: 21.4225,
          longitude: 39.8262,
          label: 'Makkah',
          source: LocationSource.manual,
        ),
      );
      expect(controller.hasTimes, isTrue);
      await controller.clearLocation();
      expect(controller.hasLocation, isFalse);
      expect(controller.hasTimes, isFalse);
      expect(controller.nextPrayer, isNull);
    });
  });

  group('ThemeController', () {
    test('persists the selected theme preference', () async {
      final LocalStorageService storage = await createStorage();
      final ThemeController theme = ThemeController(storage: storage);
      await theme.initialize();
      expect(theme.preference, AppThemePreference.system);

      await theme.setPreference(AppThemePreference.dark);
      expect(theme.preference, AppThemePreference.dark);
      expect(theme.themeMode, ThemeMode.dark);

      final ThemeController restored = ThemeController(storage: storage);
      await restored.initialize();
      expect(restored.preference, AppThemePreference.dark);
      expect(restored.themeMode, ThemeMode.dark);
    });
  });
}
