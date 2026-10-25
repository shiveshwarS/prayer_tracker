import 'dart:async';

import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/compass_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/prayer_controller.dart';
import '../../controllers/prayer_times_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/prayer_moment.dart';
import '../../theme/app_motion.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/celebration_overlay.dart';
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

class _MainShellState extends State<MainShell>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  Timer? _refreshTimer;
  late final AnimationController _tabController;
  PrayerMoment? _celebration;
  int? _lastMomentSequence;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = AnimationController(
      vsync: this,
      duration: AppMotion.standard,
    )..value = 1;
    _lastMomentSequence = widget.prayerController.lastMoment?.sequence;
    widget.prayerController.addListener(_handlePrayerMoment);
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshTimeSensitiveState(),
    );
  }

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prayerController != widget.prayerController) {
      oldWidget.prayerController.removeListener(_handlePrayerMoment);
      _lastMomentSequence = widget.prayerController.lastMoment?.sequence;
      widget.prayerController.addListener(_handlePrayerMoment);
    }
  }

  void _handlePrayerMoment() {
    final PrayerMoment? moment = widget.prayerController.lastMoment;
    if (moment == null || moment.sequence == _lastMomentSequence) {
      return;
    }
    _lastMomentSequence = moment.sequence;
    if (!moment.hasCelebration || !mounted) {
      return;
    }
    setState(() {
      _celebration = moment;
    });
  }

  void _dismissCelebration() {
    if (!mounted || _celebration == null) {
      return;
    }
    setState(() {
      _celebration = null;
    });
  }

  void _selectDestination(int index) {
    if (index == widget.navigationController.index) {
      return;
    }
    if (!MediaQuery.of(context).disableAnimations) {
      _tabController.forward(from: 0);
    } else {
      _tabController.value = 1;
    }
    widget.navigationController.select(index);
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
    widget.prayerController.removeListener(_handlePrayerMoment);
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.navigationController,
      builder: (BuildContext context, Widget? child) {
        final int index = widget.navigationController.index;
        final Animation<double> tabCurve = _tabController.drive(
          CurveTween(curve: AppMotion.enter),
        );
        final PrayerMoment? celebration = _celebration;
        return PopScope<Object?>(
          canPop: index == 0,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (!didPop) {
              _selectDestination(0);
            }
          },
          child: Stack(
            children: <Widget>[
              Scaffold(
                body: SafeArea(
                  bottom: false,
                  child: FadeTransition(
                    opacity: Tween<double>(
                      begin: 0.72,
                      end: 1,
                    ).animate(tabCurve),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.012),
                        end: Offset.zero,
                      ).animate(tabCurve),
                      child: IndexedStack(
                        index: index,
                        children: <Widget>[
                          TickerMode(
                            enabled: index == 0,
                            child: HomeView(
                              authController: widget.authController,
                              prayerController: widget.prayerController,
                              prayerTimesController:
                                  widget.prayerTimesController,
                              onOpenProfile: () => _selectDestination(2),
                              onOpenHistory: () => _selectDestination(2),
                            ),
                          ),
                          TickerMode(
                            enabled: index == 1,
                            child: CompassView(
                              compassController: widget.compassController,
                              prayerTimesController:
                                  widget.prayerTimesController,
                              isActive: index == 1,
                            ),
                          ),
                          TickerMode(
                            enabled: index == 2,
                            child: ProfileView(
                              authController: widget.authController,
                              prayerController: widget.prayerController,
                              prayerTimesController:
                                  widget.prayerTimesController,
                              themeController: widget.themeController,
                              onResetData: widget.onResetData,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                bottomNavigationBar: AppBottomNavigation(
                  selectedIndex: index,
                  onSelected: _selectDestination,
                ),
              ),
              if (celebration != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CelebrationOverlay(
                      key: ValueKey<int>(celebration.sequence),
                      moment: celebration,
                      onDismissed: _dismissCelebration,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
