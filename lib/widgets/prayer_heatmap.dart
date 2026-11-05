import 'package:flutter/material.dart';

import '../models/prayer_history.dart';
import '../theme/app_motion.dart';
import '../theme/app_palette.dart';
import '../utils/date_utils.dart';

class PrayerHeatmap extends StatefulWidget {
  const PrayerHeatmap({
    super.key,
    required this.history,
    required this.today,
  });

  final PrayerHistory history;
  final DateTime today;

  @override
  State<PrayerHeatmap> createState() => _PrayerHeatmapState();
}

class _PrayerHeatmapState extends State<PrayerHeatmap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _revealController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = AppDate.dateOnly(widget.today);
    _revealController = AnimationController(
      vsync: this,
      duration: AppMotion.entrance,
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _revealController
        ..stop()
        ..value = 1;
    }
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final DateTime today = AppDate.dateOnly(widget.today);
    final DateTime currentMonday = AppDate.addDays(
      today,
      -(today.weekday - 1),
    );
    final DateTime start = AppDate.addDays(currentMonday, -77);
    final List<List<DateTime>> weeks = <List<DateTime>>[
      for (int week = 0; week < 12; week++)
        <DateTime>[
          for (int day = 0; day < 7; day++)
            AppDate.addDays(start, week * 7 + day),
        ],
    ];
    int completeDays = 0;
    for (final List<DateTime> week in weeks) {
      for (final DateTime date in week) {
        if (!date.isAfter(today) && widget.history.isDayComplete(date)) {
          completeDays++;
        }
      }
    }
    final int selectedCount = widget.history.completedCount(_selectedDate);
    final Duration motion = AppMotion.resolve(context, AppMotion.standard);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.line),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: palette.shadow,
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'LAST 12 WEEKS',
                      style: textTheme.labelSmall?.copyWith(
                        color: palette.inkMuted,
                        fontSize: 9,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Consistency',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  '$completeDays complete',
                  style: textTheme.labelSmall?.copyWith(
                    color: palette.ink,
                    fontSize: 9,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              const double gap = 4;
              final double cellSize =
                  ((constraints.maxWidth - gap * 11) / 12).clamp(8.0, 18.0);
              final double gridWidth = cellSize * 12 + gap * 11;
              return Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: gridWidth,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (int week = 0; week < weeks.length; week++) ...<
                        Widget
                      >[
                        if (week > 0) const SizedBox(width: gap),
                        _HeatWeek(
                          week: week,
                          days: weeks[week],
                          today: today,
                          selectedDate: _selectedDate,
                          history: widget.history,
                          revealController: _revealController,
                          cellSize: cellSize,
                          gap: gap,
                          onSelect: (DateTime date) {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Text(
                'Less',
                style: textTheme.labelSmall?.copyWith(
                  color: palette.inkMuted,
                  fontSize: 9,
                ),
              ),
              const SizedBox(width: 6),
              for (int level = 0; level <= 5; level++) ...<Widget>[
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: palette.contributionLevels[level],
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: level == 0 ? palette.line : Colors.transparent,
                    ),
                  ),
                ),
                if (level < 5) const SizedBox(width: 3),
              ],
              const SizedBox(width: 6),
              Text(
                'More',
                style: textTheme.labelSmall?.copyWith(
                  color: palette.inkMuted,
                  fontSize: 9,
                ),
              ),
              const Spacer(),
              Text(
                '1 square = 1 day',
                style: textTheme.labelSmall?.copyWith(
                  color: palette.inkMuted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          AnimatedSwitcher(
            duration: motion,
            switchInCurve: AppMotion.enter,
            switchOutCurve: AppMotion.exit,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.12),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              '${AppDate.formatCompactDate(_selectedDate)} · '
              '$selectedCount of 5 prayers',
              key: ValueKey<String>(AppDate.dateKey(_selectedDate)),
              style: textTheme.bodySmall?.copyWith(
                color: palette.inkMuted,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeatWeek extends StatelessWidget {
  const _HeatWeek({
    required this.week,
    required this.days,
    required this.today,
    required this.selectedDate,
    required this.history,
    required this.revealController,
    required this.cellSize,
    required this.gap,
    required this.onSelect,
  });

  final int week;
  final List<DateTime> days;
  final DateTime today;
  final DateTime selectedDate;
  final PrayerHistory history;
  final AnimationController revealController;
  final double cellSize;
  final double gap;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final double start = (week / 12) * 0.62;
    final double end = (start + 0.38).clamp(0.0, 1.0);
    final Animation<double> animation = CurvedAnimation(
      parent: revealController,
      curve: Interval(start, end, curve: AppMotion.enter),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.16),
          end: Offset.zero,
        ).animate(animation),
        child: Column(
          children: <Widget>[
            for (final DateTime date in days)
              _HeatCell(
                date: date,
                count: date.isAfter(today) ? 0 : history.completedCount(date),
                isFuture: date.isAfter(today),
                isSelected: AppDate.sameDay(date, selectedDate),
                cellSize: cellSize,
                gap: gap,
                onTap: date.isAfter(today) ? null : () => onSelect(date),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({
    required this.date,
    required this.count,
    required this.isFuture,
    required this.isSelected,
    required this.cellSize,
    required this.gap,
    required this.onTap,
  });

  final DateTime date;
  final int count;
  final bool isFuture;
  final bool isSelected;
  final double cellSize;
  final double gap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final Duration motion = AppMotion.resolve(
      context,
      const Duration(milliseconds: 180),
    );
    return Semantics(
      button: !isFuture,
      selected: isSelected,
      label:
          '${AppDate.formatLongDate(date)}, '
          '${isFuture ? 'upcoming' : '$count of 5 prayers completed'}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: motion,
          curve: AppMotion.enter,
          width: cellSize,
          height: cellSize,
          margin: EdgeInsets.only(bottom: gap),
          decoration: BoxDecoration(
            color:
                isFuture
                    ? Colors.transparent
                    : palette.contributionColor(count),
            borderRadius: BorderRadius.circular(cellSize * 0.28),
            border: Border.all(
              color:
                  isSelected
                      ? palette.ink
                      : isFuture
                      ? palette.line.withValues(alpha: 0.55)
                      : Colors.transparent,
              width: isSelected ? 1.6 : 1,
            ),
          ),
        ),
      ),
    );
  }
}
