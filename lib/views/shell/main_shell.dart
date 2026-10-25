import 'dart:async';

import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/compass_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/prayer_controller.dart';
import '../../controllers/prayer_times_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../compass/compass_view.dart';
import '../home/home_view.dart';
import '../profile/profile_view.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.authController,
    required this.navigationController,
    required this.prayerController,
    required this.prayerTimesController,
    required this.compassController,
    required this.themeController,
    required this.onResetData,
  });

  final AuthController authController;
  final NavigationController navigationController;
  final PrayerController prayerController;
  final PrayerTimesController prayerTimesController;
  final CompassController compassController;
  final ThemeController themeController;
  final Future<void> Function() onResetData;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshTimeSensitiveState(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshTimeSensitiveState();
    }
  }

  void _refreshTimeSensitiveState() {
    if (!mounted) {
      return;
    }
    widget.prayerController.refreshToday();
    widget.prayerTimesController.refreshForToday();
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.navigationController,
      builder: (BuildContext context, Widget? child) {
        final int index = widget.navigationController.index;
        return PopScope<Object?>(
          canPop: index == 0,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (!didPop) {
              widget.navigationController.goHome();
            }
          },
          child: Scaffold(
            body: SafeArea(
              bottom: false,
              child: IndexedStack(
                index: index,
                children: <Widget>[
                  TickerMode(
                    enabled: index == 0,
                    child: HomeView(
                      authController: widget.authController,
                      prayerController: widget.prayerController,
                      prayerTimesController: widget.prayerTimesController,
                      onOpenProfile: widget.navigationController.goProfile,
                      onOpenHistory: widget.navigationController.goProfile,
                    ),
                  ),
                  TickerMode(
                    enabled: index == 1,
                    child: CompassView(
                      compassController: widget.compassController,
                      prayerTimesController: widget.prayerTimesController,
                      isActive: index == 1,
                    ),
                  ),
                  TickerMode(
                    enabled: index == 2,
                    child: ProfileView(
                      authController: widget.authController,
                      prayerController: widget.prayerController,
                      prayerTimesController: widget.prayerTimesController,
                      themeController: widget.themeController,
                      onResetData: widget.onResetData,
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: AppBottomNavigation(
              selectedIndex: index,
              onSelected: widget.navigationController.select,
            ),
          ),
        );
      },
    );
  }
}
