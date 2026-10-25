import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
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
                child: AnimatedSwitcher(
                  duration: AppMotion.resolve(
                    context,
                    const Duration(milliseconds: 220),
                  ),
                  switchInCurve: AppMotion.enter,
                  switchOutCurve: AppMotion.exit,
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                  ) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.35),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    actionLabel!,
                    key: ValueKey<String>(actionLabel!),
                    style: textTheme.labelMedium?.copyWith(
                      color: palette.inkMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              : TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}
