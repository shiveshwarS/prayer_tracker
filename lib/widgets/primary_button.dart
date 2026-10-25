import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          disabledBackgroundColor: palette.ink.withValues(alpha: 0.55),
          disabledForegroundColor: palette.inverseInk,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child:
              isLoading
                  ? SizedBox(
                    key: const ValueKey<String>('loading'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: palette.inverseInk,
                    ),
                  )
                  : Row(
                    key: const ValueKey<String>('label'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (icon != null) ...<Widget>[
                        Icon(icon, size: 19),
                        const SizedBox(width: 10),
                      ],
                      Text(label),
                    ],
                  ),
        ),
      ),
    );
  }
}
