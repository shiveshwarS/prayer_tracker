import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? eyebrow;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (eyebrow != null) ...<Widget>[
                Text(
                  eyebrow!.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: palette.inkMuted,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                title,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null)
          onAction == null
              ? Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  actionLabel!,
                  style: textTheme.labelMedium?.copyWith(
                    color: palette.inkMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
              : TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}
