import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/prayer_controller.dart';
import '../../controllers/prayer_times_controller.dart';
import '../../models/prayer.dart';
import '../../models/prayer_times.dart';
import '../../theme/app_palette.dart';
import '../../utils/date_utils.dart';
import '../../widgets/companion_widget.dart';
import '../../widgets/location_sheet.dart';
import '../../widgets/next_prayer_card.dart';
import '../../widgets/prayer_card.dart';
import '../../widgets/progress_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.authController,
    required this.prayerController,
    required this.prayerTimesController,
    required this.onOpenProfile,
    required this.onOpenHistory,
  });

  final AuthController authController;
  final PrayerController prayerController;
  final PrayerTimesController prayerTimesController;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        authController,
        prayerController,
        prayerTimesController,
      ]),
      builder: (BuildContext context, Widget? child) {
        final AppPalette palette = context.palette;
        final TextTheme textTheme = Theme.of(context).textTheme;
        final DateTime today = prayerController.today;
        final String firstName = authController.user?.firstName ?? 'friend';
        final NextPrayerInfo? nextPrayer = prayerTimesController.nextPrayer;

        return CustomScrollView(
          key: const ValueKey<String>('home-view'),
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                AppDate.formatLongDate(today).toUpperCase(),
                                style: textTheme.labelSmall?.copyWith(
                                  color: palette.inkMuted,
                                  fontSize: 9,
                                  letterSpacing: 1.15,
                                ),
                              ),
                            ),
                            _ProfileButton(
                              initial: authController.user?.initial ?? 'N',
                              onTap: onOpenProfile,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Assalamu alaikum,',
                          style: textTheme.bodyMedium?.copyWith(
                            color: palette.inkMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          firstName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.displayMedium?.copyWith(
                            fontSize: 46,
                            height: 1,
                            letterSpacing: -0.7,
                          ),
                        ),
                        const SizedBox(height: 22),
                        ProgressCard(
                          completed: prayerController.todayCompleted,
                          total: PrayerId.values.length,
                          onViewHistory: onOpenHistory,
                        ),
                        const SizedBox(height: 14),
                        if (nextPrayer != null)
                          NextPrayerCard(
                            nextPrayer: nextPrayer,
                            locationLabel:
                                prayerTimesController.location?.label ??
                                'Saved location',
                            onEditLocation:
                                () => LocationSheet.show(
                                  context,
                                  prayerTimesController,
                                ),
                          )
                        else if (!prayerTimesController.hasLocation)
                          _LocationPrompt(
                            onOpenLocation:
                                () => LocationSheet.show(
                                  context,
                                  prayerTimesController,
                                ),
                          )
                        else
                          _TimesUnavailable(
                            message:
                                prayerTimesController.calculationError ??
                                'Prayer times could not be calculated for this location.',
                            onReview:
                                () => LocationSheet.show(
                                  context,
                                  prayerTimesController,
                                ),
                          ),
                        const SizedBox(height: 28),
                        SectionHeader(
                          eyebrow: 'YOUR DAY',
                          title: 'Today\'s prayers',
                          actionLabel:
                              '${prayerController.todayCompleted}/${PrayerId.values.length}',
                        ),
                        const SizedBox(height: 12),
                        if (prayerController.persistenceFailed) ...<Widget>[
                          const _PersistenceNotice(),
                          const SizedBox(height: 10),
                        ],
                        for (final PrayerId prayer
                            in PrayerId.values) ...<Widget>[
                          PrayerCard(
                            prayer: prayer,
                            time: prayerTimesController.timeFor(prayer),
                            completed: prayerController.isCompleted(prayer),
                            onToggle: () {
                              prayerController.togglePrayer(prayer);
                              HapticFeedback.selectionClick();
                            },
                          ),
                          if (prayer != PrayerId.values.last)
                            const SizedBox(height: 10),
                        ],
                        const SizedBox(height: 24),
                        CompanionWidget(
                          summary: prayerController.summary,
                          onOpenCalendar: onOpenHistory,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: StatCard(
                                label: 'Current streak',
                                value: '${prayerController.currentStreak}',
                                caption:
                                    prayerController.currentStreak == 1
                                        ? 'complete day in a row'
                                        : 'complete days in a row',
                                icon: Icons.local_fire_department_outlined,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: StatCard(
                                label: 'Longest streak',
                                value: '${prayerController.longestStreak}',
                                caption:
                                    prayerController.longestStreak == 1
                                        ? 'complete day to beat'
                                        : 'complete days to beat',
                                icon: Icons.emoji_events_outlined,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({required this.initial, required this.onTap});

  final String initial;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: 'Open profile',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: palette.inverse,
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: textTheme.titleLarge?.copyWith(
              color: palette.inverseInk,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationPrompt extends StatelessWidget {
  const _LocationPrompt({required this.onOpenLocation});

  final VoidCallback onOpenLocation;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: palette.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: palette.ink,
              size: 20,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Prayer times, where you are',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Set your location to see accurate prayer times and the Qibla. You can use the device or enter coordinates manually.',
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.inkMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 9),
                TextButton(
                  onPressed: onOpenLocation,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(48, 38),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Set location'),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 15),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimesUnavailable extends StatelessWidget {
  const _TimesUnavailable({required this.message, required this.onReview});

  final String message;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline_rounded, size: 18, color: palette.ink),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(
                color: palette.inkMuted,
                height: 1.45,
              ),
            ),
          ),
          TextButton(
            onPressed: onReview,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(48, 36),
            ),
            child: const Text('Review'),
          ),
        ],
      ),
    );
  }
}

class _PersistenceNotice extends StatelessWidget {
  const _PersistenceNotice();

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.line),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.cloud_off_outlined, size: 16, color: palette.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Changes are active for this session, but could not be saved on this device.',
              style: textTheme.bodySmall?.copyWith(color: palette.error),
            ),
          ),
        ],
      ),
    );
  }
}
