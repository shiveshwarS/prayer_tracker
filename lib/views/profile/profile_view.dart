import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/prayer_controller.dart';
import '../../controllers/prayer_times_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/user_model.dart';
import '../../theme/app_palette.dart';
import '../../utils/date_utils.dart';
import '../../widgets/companion_widget.dart';
import '../../widgets/edit_profile_sheet.dart';
import '../../widgets/section_header.dart';
import '../../widgets/settings_sheet.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/streak_calendar.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({
    super.key,
    required this.authController,
    required this.prayerController,
    required this.prayerTimesController,
    required this.themeController,
    required this.onResetData,
  });

  final AuthController authController;
  final PrayerController prayerController;
  final PrayerTimesController prayerTimesController;
  final ThemeController themeController;
  final Future<void> Function() onResetData;

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
        final UserModel? user = authController.user;
        final summary = prayerController.summary;
        final String locationLabel =
            prayerTimesController.location?.label ?? 'No prayer location saved';

        return CustomScrollView(
          key: const ValueKey<String>('profile-view'),
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
                        Text(
                          'PROFILE',
                          style: textTheme.labelSmall?.copyWith(
                            color: palette.inkMuted,
                            fontSize: 9,
                            letterSpacing: 1.35,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Your quiet corner.',
                          style: textTheme.displayMedium?.copyWith(
                            fontSize: 42,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _ProfileHero(
                          user: user,
                          locationLabel: locationLabel,
                          totalSuccessfulDays: summary.totalSuccessfulDays,
                          onEdit:
                              user == null
                                  ? null
                                  : () => EditProfileSheet.show(
                                    context,
                                    authController,
                                  ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: StatCard(
                                label: 'Current streak',
                                value: '${summary.currentStreak}',
                                caption:
                                    summary.currentStreak == 1
                                        ? 'complete day in a row'
                                        : 'complete days in a row',
                                icon: Icons.local_fire_department_outlined,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: StatCard(
                                label: 'Longest streak',
                                value: '${summary.longestStreak}',
                                caption:
                                    summary.longestStreak == 1
                                        ? 'complete day to beat'
                                        : 'complete days to beat',
                                icon: Icons.emoji_events_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CompanionWidget(summary: summary),
                        const SizedBox(height: 24),
                        SectionHeader(
                          eyebrow: 'HISTORY',
                          title: 'Days of prayer',
                        ),
                        const SizedBox(height: 12),
                        StreakCalendar(
                          history: prayerController.history,
                          today: prayerController.today,
                        ),
                        const SizedBox(height: 24),
                        SectionHeader(
                          eyebrow: 'PREFERENCES',
                          title: 'Settings',
                        ),
                        const SizedBox(height: 12),
                        _SettingsTile(
                          icon: Icons.tune_rounded,
                          title: 'Preferences',
                          subtitle:
                              'Appearance, calculation method, location, and local data',
                          onTap:
                              () => SettingsSheet.show(
                                context,
                                themeController: themeController,
                                prayerTimesController: prayerTimesController,
                                onResetData: onResetData,
                              ),
                        ),
                        const SizedBox(height: 10),
                        _SettingsTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Edit profile',
                          subtitle: user?.phone ?? 'Your local profile details',
                          onTap:
                              user == null
                                  ? null
                                  : () => EditProfileSheet.show(
                                    context,
                                    authController,
                                  ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: palette.surfaceMuted,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 15,
                                color: palette.inkMuted,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Your profile, prayers, and preferences are stored only on this device. No account or cloud sync is used.',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: palette.inkMuted,
                                    fontSize: 11,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        Center(
                          child: Text(
                            'NOOR · A LOCAL-FIRST PRAYER COMPANION',
                            style: textTheme.labelSmall?.copyWith(
                              color: palette.inkMuted,
                              fontSize: 8,
                              letterSpacing: 1.1,
                            ),
                          ),
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

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.user,
    required this.locationLabel,
    required this.totalSuccessfulDays,
    required this.onEdit,
  });

  final UserModel? user;
  final String locationLabel;
  final int totalSuccessfulDays;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DateTime? createdAt = user?.createdAt;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: palette.line),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: palette.inverse,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(
                  user?.initial ?? 'N',
                  style: textTheme.headlineSmall?.copyWith(
                    color: palette.inverseInk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user?.name ?? 'Your profile',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      user?.phone ?? 'Stored on this device',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: palette.inkMuted,
                      ),
                    ),
                    if (createdAt != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        'With Noor since ${AppDate.formatMonthYear(createdAt)}',
                        style: textTheme.labelSmall?.copyWith(
                          color: palette.inkMuted,
                          fontSize: 8.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit profile',
                icon: const Icon(Icons.edit_outlined, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: palette.line),
          const SizedBox(height: 13),
          Row(
            children: <Widget>[
              Expanded(
                child: _MiniDetail(
                  icon: Icons.location_on_outlined,
                  label: 'Prayer location',
                  value: locationLabel,
                ),
              ),
              Container(width: 1, height: 32, color: palette.line),
              const SizedBox(width: 14),
              Expanded(
                child: _MiniDetail(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Complete days',
                  value: AppDate.formatDays(totalSuccessfulDays),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniDetail extends StatelessWidget {
  const _MiniDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: palette.inkMuted),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: palette.inkMuted,
                  fontSize: 7.5,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: palette.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.line),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: palette.ink),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: palette.inkMuted,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 19,
              color: palette.inkMuted,
            ),
          ],
        ),
      ),
    );
  }
}
