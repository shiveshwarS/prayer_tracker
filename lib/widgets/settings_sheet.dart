import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/prayer_times_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/prayer_settings.dart';
import '../models/saved_location.dart';
import '../services/prayer_alarm_service.dart';
import '../theme/app_palette.dart';
import '../utils/date_utils.dart';
import 'location_sheet.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({
    super.key,
    required this.themeController,
    required this.prayerTimesController,
    this.onResetData,
  });

  final ThemeController themeController;
  final PrayerTimesController prayerTimesController;
  final Future<void> Function()? onResetData;

  static Future<void> show(
    BuildContext context, {
    required ThemeController themeController,
    required PrayerTimesController prayerTimesController,
    Future<void> Function()? onResetData,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return SettingsSheet(
          themeController: themeController,
          prayerTimesController: prayerTimesController,
          onResetData: onResetData,
        );
      },
    );
  }

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late final Listenable _animation = Listenable.merge(<Listenable>[
    widget.themeController,
    widget.prayerTimesController,
  ]);

  Future<void> _confirmReset() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reset all local data?'),
          content: const Text(
            'Your profile, prayer history, streak, saved location, and preferences will be deleted from this device. This cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              child: const Text('Reset everything'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await widget.onResetData?.call();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        final PrayerTimesController prayerTimes = widget.prayerTimesController;
        final SavedLocation? location = prayerTimes.location;
        final PrayerSettings settings = prayerTimes.settings;

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.92,
            maxWidth: 620,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'PREFERENCES',
                            style: textTheme.labelSmall?.copyWith(
                              color: palette.inkMuted,
                              letterSpacing: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Settings',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsCard(
                  title: 'Appearance',
                  description:
                      'Noor follows your device by default. Your choice is saved on this device.',
                  child: Row(
                    children: <Widget>[
                      for (final AppThemePreference preference
                          in AppThemePreference.values) ...<Widget>[
                        Expanded(
                          child: _SelectionButton(
                            label: preference.label,
                            icon: _themeIcon(preference),
                            selected:
                                widget.themeController.preference == preference,
                            onTap:
                                () => widget.themeController.setPreference(
                                  preference,
                                ),
                          ),
                        ),
                        if (preference != AppThemePreference.values.last)
                          const SizedBox(width: 7),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsCard(
                  title: 'Prayer alarms',
                  description:
                      'Full-screen alarm like a clock app for all prayers. Works even if the app is closed.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Enable prayer alarms'),
                        subtitle: const Text('Alarm for Fajr, Dhuhr, Asr, Maghrib, Isha'),
                        value: settings.alarm.enabled,
                        onChanged: (bool value) async {
                          await PrayerAlarmService.instance.ensurePermissions();
                          await widget.prayerTimesController.updateAlarmSettings(
                            settings.alarm.copyWith(enabled: value),
                          );
                          setState(() {});
                        },
                      ),
                      if (settings.alarm.enabled) ...<Widget>[
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Use custom Adhan sound'),
                          subtitle: const Text('Toggle between default sound and custom Adhan sound'),
                          value: settings.alarm.useCustomSound,
                          onChanged: (bool value) async {
                            await widget.prayerTimesController.updateAlarmSettings(
                              settings.alarm.copyWith(useCustomSound: value),
                            );
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: () async {
                            await PrayerAlarmService.instance.ensurePermissions();
                            await PrayerAlarmService.instance.scheduleTestAlarm();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Test alarm scheduled for 10 seconds from now')),
                            );
                          },
                          icon: const Icon(Icons.alarm_rounded),
                          label: const Text('Test full-screen alarm'),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsCard(
                  title: 'Prayer calculation',
                  description:
                      'Calculation methods differ by region and scholarly convention.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      DropdownButtonFormField<PrayerCalculationMethod>(
                        initialValue: settings.method,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Calculation method',
                        ),
                        items: <DropdownMenuItem<PrayerCalculationMethod>>[
                          for (final PrayerCalculationMethod method
                              in PrayerCalculationMethod.values)
                            DropdownMenuItem<PrayerCalculationMethod>(
                              value: method,
                              child: Text(
                                method.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (PrayerCalculationMethod? method) {
                          if (method != null) {
                            prayerTimes.setMethod(method);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Asr timing',
                        style: textTheme.bodySmall?.copyWith(
                          color: palette.inkMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: <Widget>[
                          for (final AsrMadhab madhab
                              in AsrMadhab.values) ...<Widget>[
                            Expanded(
                              child: _SelectionButton(
                                label: madhab.label,
                                selected: settings.madhab == madhab,
                                onTap: () => prayerTimes.setMadhab(madhab),
                              ),
                            ),
                            if (madhab != AsrMadhab.values.last)
                              const SizedBox(width: 7),
                          ],
                        ],
                      ),
                      if (prayerTimes.settingsError != null) ...<Widget>[
                        const SizedBox(height: 10),
                        Text(
                          prayerTimes.settingsError!,
                          style: textTheme.bodySmall?.copyWith(
                            color: palette.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsCard(
                  title: 'Prayer location',
                  description:
                      'Used only for prayer times and Qibla direction on this device.',
                  child: InkWell(
                    onTap:
                        () => LocationSheet.show(
                          context,
                          widget.prayerTimesController,
                        ),
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: palette.surfaceMuted,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            location == null
                                ? Icons.location_off_outlined
                                : Icons.location_on_outlined,
                            size: 19,
                            color: palette.ink,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  location?.label ?? 'No location saved',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (location != null) ...<Widget>[
                                  const SizedBox(height: 2),
                                  Text(
                                    AppDate.formatCoordinates(
                                      location.latitude,
                                      location.longitude,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: palette.inkMuted,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
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
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsCard(
                  title: 'Your data',
                  description:
                      'Noor stores your profile and prayer history only on this device.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      OutlinedButton.icon(
                        onPressed:
                            widget.onResetData == null ? null : _confirmReset,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: palette.error,
                          side: BorderSide(color: palette.error),
                        ),
                        icon: const Icon(Icons.restart_alt_rounded, size: 18),
                        label: const Text('Reset all local data'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'NOOR · PRIVATE BY DESIGN',
                    style: textTheme.labelSmall?.copyWith(
                      color: palette.inkMuted,
                      fontSize: 9,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _themeIcon(AppThemePreference preference) {
    switch (preference) {
      case AppThemePreference.system:
        return Icons.brightness_auto_outlined;
      case AppThemePreference.light:
        return Icons.light_mode_outlined;
      case AppThemePreference.dark:
        return Icons.dark_mode_outlined;
    }
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(
            description,
            style: textTheme.bodySmall?.copyWith(
              color: palette.inkMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SelectionButton extends StatelessWidget {
  const _SelectionButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color foreground = selected ? palette.inverseInk : palette.ink;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? palette.ink : palette.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 17, color: foreground),
                const SizedBox(height: 4),
              ],
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
