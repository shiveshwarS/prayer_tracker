import 'package:flutter/material.dart';

import '../models/prayer.dart';
import '../models/prayer_history.dart';
import '../theme/app_palette.dart';
import '../utils/calendar_utils.dart';
import '../utils/date_utils.dart';

class StreakCalendar extends StatefulWidget {
  const StreakCalendar({super.key, required this.history, required this.today});

  final PrayerHistory history;
  final DateTime today;

  @override
  State<StreakCalendar> createState() => _StreakCalendarState();
}

class _StreakCalendarState extends State<StreakCalendar> {
  late DateTime _visibleMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(widget.today.year, widget.today.month);
  }

  @override
  void didUpdateWidget(covariant StreakCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!AppDate.sameDay(oldWidget.today, widget.today)) {
      final DateTime todayMonth = DateTime(
        widget.today.year,
        widget.today.month,
      );
      if (_visibleMonth.isAfter(todayMonth)) {
        _visibleMonth = todayMonth;
      }
    }
  }

  bool get _isCurrentMonth {
    return _visibleMonth.year == widget.today.year &&
        _visibleMonth.month == widget.today.month;
  }

  void _showPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
      _selectedDate = null;
    });
  }

  void _showNextMonth() {
    if (_isCurrentMonth) {
      return;
    }
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
      _selectedDate = null;
    });
  }

  void _showToday() {
    setState(() {
      _visibleMonth = DateTime(widget.today.year, widget.today.month);
      _selectedDate = AppDate.dateOnly(widget.today);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final MonthGrid grid = MonthGrid.forMonth(_visibleMonth);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'PRAYER RHYTHM',
                      style: textTheme.labelSmall?.copyWith(
                        color: palette.inkMuted,
                        fontSize: 9,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        AppDate.formatMonthYear(_visibleMonth),
                        key: ValueKey<String>(AppDate.dateKey(_visibleMonth)),
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isCurrentMonth)
                TextButton(
                  onPressed: _showToday,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                  ),
                  child: const Text('Today'),
                ),
              _MonthArrowButton(
                icon: Icons.chevron_left_rounded,
                tooltip: 'Previous month',
                onPressed: _showPreviousMonth,
              ),
              const SizedBox(width: 3),
              _MonthArrowButton(
                icon: Icons.chevron_right_rounded,
                tooltip: 'Next month',
                onPressed: _isCurrentMonth ? null : _showNextMonth,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: <Widget>[
              for (
                int index = 0;
                index < AppDate.weekdayInitials.length;
                index++
              )
                Expanded(
                  child: Center(
                    child: Text(
                      AppDate.weekdayInitials[index],
                      style: textTheme.labelSmall?.copyWith(
                        color: palette.inkMuted,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              childAspectRatio: 0.82,
            ),
            itemCount: grid.cells.length,
            itemBuilder: (BuildContext context, int index) {
              final DateTime? date = grid.cells[index].date;
              if (date == null) {
                return const SizedBox.shrink();
              }
              return _DayCell(
                date: date,
                today: widget.today,
                completed: widget.history.completedForDate(date),
                selected:
                    _selectedDate != null &&
                    AppDate.sameDay(_selectedDate!, date),
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 14),
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
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: palette.contributionLevels[level],
                    borderRadius: BorderRadius.circular(3.5),
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
                '1 dot = 1 prayer',
                style: textTheme.labelSmall?.copyWith(
                  color: palette.inkMuted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child:
                _selectedDate == null
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: _DayDetail(
                        date: _selectedDate!,
                        completed: widget.history.completedForDate(
                          _selectedDate!,
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

class _MonthArrowButton extends StatelessWidget {
  const _MonthArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        minimumSize: const Size(38, 38),
        maximumSize: const Size(38, 38),
        foregroundColor: palette.ink,
        disabledForegroundColor: palette.inkMuted.withValues(alpha: 0.35),
        side: BorderSide(
          color: onPressed == null ? palette.line : palette.line,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      icon: Icon(icon, size: 19),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.today,
    required this.completed,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final DateTime today;
  final Set<PrayerId> completed;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int count = completed.length;
    final bool isFuture = AppDate.dateOnly(
      date,
    ).isAfter(AppDate.dateOnly(today));
    final bool isToday = AppDate.sameDay(date, today);
    final Color background =
        isFuture ? Colors.transparent : palette.contributionColor(count);
    final Color foreground =
        isFuture
            ? palette.inkMuted.withValues(alpha: 0.38)
            : (background.computeLuminance() > 0.42
                ? palette.ink
                : palette.inverseInk);
    final Color dotColor = foreground.withValues(alpha: 0.75);
    final Color emptyDotColor = foreground.withValues(alpha: 0.2);

    return Semantics(
      button: !isFuture,
      enabled: !isFuture,
      selected: selected,
      label:
          isFuture
              ? '${date.day} ${AppDate.monthNames[date.month - 1]}, upcoming'
              : '${date.day} ${AppDate.monthNames[date.month - 1]}, '
                  '$count of 5 prayers completed',
      child: GestureDetector(
        onTap: isFuture ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(2, 5, 2, 4),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color:
                  selected
                      ? foreground
                      : isToday
                      ? foreground.withValues(alpha: 0.72)
                      : Colors.transparent,
              width: selected ? 2 : 1.3,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${date.day}',
                style: textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontSize: 10.5,
                  height: 1,
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final PrayerId prayer in PrayerId.values) ...<Widget>[
                    Container(
                      width: 3.4,
                      height: 3.4,
                      decoration: BoxDecoration(
                        color:
                            completed.contains(prayer)
                                ? dotColor
                                : emptyDotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (prayer != PrayerId.values.last)
                      const SizedBox(width: 1.2),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayDetail extends StatelessWidget {
  const _DayDetail({required this.date, required this.completed});

  final DateTime date;
  final Set<PrayerId> completed;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool allComplete = completed.length == PrayerId.values.length;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  AppDate.formatLongDate(date),
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${completed.length}/5',
                style: textTheme.labelSmall?.copyWith(
                  color: palette.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              for (final PrayerId prayer in PrayerId.values)
                _PrayerDetailChip(
                  label: prayer.label,
                  completed: completed.contains(prayer),
                  allComplete: allComplete,
                ),
            ],
          ),
          if (completed.isEmpty) ...<Widget>[
            const SizedBox(height: 9),
            Text(
              'No prayers were recorded for this day.',
              style: textTheme.bodySmall?.copyWith(
                color: palette.inkMuted,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrayerDetailChip extends StatelessWidget {
  const _PrayerDetailChip({
    required this.label,
    required this.completed,
    required this.allComplete,
  });

  final String label;
  final bool completed;
  final bool allComplete;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color foreground =
        completed
            ? (allComplete ? palette.inverseInk : palette.ink)
            : palette.inkMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color:
            completed
                ? (allComplete ? palette.ink : palette.surface)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: completed ? Colors.transparent : palette.line,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            completed ? Icons.check_rounded : Icons.remove_rounded,
            size: 11,
            color: foreground,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: foreground,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
