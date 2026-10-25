import 'package:flutter/material.dart';

import '../models/prayer_times.dart';
import '../theme/app_palette.dart';
import '../utils/date_utils.dart';

class NextPrayerCard extends StatelessWidget {
  const NextPrayerCard({
    super.key,
    required this.nextPrayer,
    required this.locationLabel,
    required this.onEditLocation,
  });

  final NextPrayerInfo nextPrayer;
  final String locationLabel;
  final VoidCallback onEditLocation;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String dayLabel = nextPrayer.isTomorrow ? 'Tomorrow' : 'Today';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.line),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: palette.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.nights_stay_outlined,
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
                  'NEXT PRAYER · $dayLabel',
                  style: textTheme.labelSmall?.copyWith(
                    color: palette.inkMuted,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        nextPrayer.prayer.label,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppDate.formatTime(nextPrayer.time),
                      style: textTheme.titleMedium?.copyWith(
                        color: palette.inkMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: palette.inkMuted,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        locationLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: palette.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEditLocation,
            tooltip: 'Change prayer location',
            icon: const Icon(Icons.tune_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}
