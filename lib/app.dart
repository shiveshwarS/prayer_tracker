import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controllers/auth_controller.dart';
import 'controllers/compass_controller.dart';
import 'controllers/navigation_controller.dart';
import 'controllers/prayer_controller.dart';
import 'controllers/prayer_times_controller.dart';
import 'controllers/theme_controller.dart';
import 'services/local_storage_service.dart';
import 'services/location_service.dart';
import 'services/prayer_time_service.dart';
import 'theme/app_palette.dart';
import 'theme/app_theme.dart';
import 'views/shell/main_shell.dart';
import 'views/signup/signup_view.dart';
import 'views/splash/splash_view.dart';
import 'widgets/app_logo.dart';
import 'widgets/primary_button.dart';

class NoorApp extends StatefulWidget {
  const NoorApp({super.key});

  @override
  State<NoorApp> createState() => _NoorAppState();
}

class _NoorAppState extends State<NoorApp> {
  LocalStorageService? _storage;
  AuthController? _authController;
  ThemeController? _themeController;
  NavigationController? _navigationController;
  PrayerController? _prayerController;
  PrayerTimesController? _prayerTimesController;
  CompassController? _compassController;

  bool _ready = false;
  bool _startupFailed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      final LocalStorageService storage = await LocalStorageService.create();
      final AuthController auth = AuthController(storage: storage);
      final ThemeController theme = ThemeController(storage: storage);
      final NavigationController navigation = NavigationController();
      final PrayerController prayer = PrayerController(storage: storage);
      final PrayerTimesController prayerTimes = PrayerTimesController(
        prayerTimeService: const PrayerTimeService(),
        locationService: const LocationService(),
        storage: storage,
      );
      final CompassController compass = CompassController(
        prayerTimesController: prayerTimes,
      );

      _storage = storage;
      _authController = auth;
      _themeController = theme;
      _navigationController = navigation;
      _prayerController = prayer;
      _prayerTimesController = prayerTimes;
      _compassController = compass;

      await Future.wait<void>(<Future<void>>[
        auth.initialize(),
        theme.initialize(),
        prayer.initialize(),
        prayerTimes.initialize(),
      ]);

      final Duration minimumSplash = const Duration(milliseconds: 1050);
      if (stopwatch.elapsed < minimumSplash) {
        await Future<void>.delayed(minimumSplash - stopwatch.elapsed);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _ready = true;
        _startupFailed = false;
      });
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() {
        _ready = true;
        _startupFailed = true;
      });
    }
  }

  void _retryStartup() {
    _disposeControllers();
    setState(() {
      _ready = false;
      _startupFailed = false;
    });
    unawaited(_bootstrap());
  }

  Future<void> _resetAllData() async {
    final LocalStorageService? storage = _storage;
    if (storage == null) {
      return;
    }
    await _prayerController?.flush();
    await storage.clearAll();
    _compassController?.setActive(false);
    _navigationController?.select(0);
    _prayerController?.clearLocal();
    _prayerTimesController?.resetLocal();
    _themeController?.resetLocal();
    _authController?.clearLocalUser();
  }

  void _disposeControllers() {
    _compassController?.dispose();
    _compassController = null;
    _navigationController?.dispose();
    _navigationController = null;
    _prayerTimesController?.dispose();
    _prayerTimesController = null;
    _prayerController?.dispose();
    _prayerController = null;
    _authController?.dispose();
    _authController = null;
    _themeController?.dispose();
    _themeController = null;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController? themeController = _themeController;
    final AuthController? authController = _authController;

    if (themeController == null || authController == null) {
      return _buildMaterialApp(context);
    }

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        themeController,
        authController,
      ]),
      builder: (BuildContext context, Widget? child) {
        return _buildMaterialApp(context);
      },
    );
  }

  Widget _buildMaterialApp(BuildContext context) {
    return MaterialApp(
      title: 'Noor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeController?.themeMode ?? ThemeMode.system,
      themeAnimationDuration: const Duration(milliseconds: 300),
      themeAnimationCurve: Curves.easeOutCubic,
      builder: (BuildContext context, Widget? child) {
        final AppPalette palette = context.palette;
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: palette.canvas,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (!_ready) {
      return const SplashView();
    }
    if (_startupFailed) {
      return _StartupErrorView(onRetry: _retryStartup);
    }

    final AuthController? auth = _authController;
    if (auth == null) {
      return const SplashView();
    }
    if (!auth.isSignedIn) {
      return SignupView(controller: auth);
    }

    final PrayerController? prayer = _prayerController;
    final PrayerTimesController? prayerTimes = _prayerTimesController;
    final CompassController? compass = _compassController;
    final ThemeController? theme = _themeController;
    final NavigationController? navigation = _navigationController;
    if (prayer == null ||
        prayerTimes == null ||
        compass == null ||
        theme == null ||
        navigation == null) {
      return const SplashView();
    }

    return MainShell(
      authController: auth,
      navigationController: navigation,
      prayerController: prayer,
      prayerTimesController: prayerTimes,
      compassController: compass,
      themeController: theme,
      onResetData: _resetAllData,
    );
  }
}

class _StartupErrorView extends StatelessWidget {
  const _StartupErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const AppLogo(size: 64),
                  const SizedBox(height: 24),
                  Text(
                    'Noor could not open\nlocal storage.',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your data stays on this device, so local storage is required. Check available storage and try again.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: palette.inkMuted,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Try again',
                    icon: Icons.refresh_rounded,
                    onPressed: onRetry,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
