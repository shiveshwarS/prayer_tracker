import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: Row(
            children: <Widget>[
              _NavDestination(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                isSelected: selectedIndex == 0,
                onTap: () => onSelected(0),
              ),
              _NavDestination(
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore_rounded,
                label: 'Qibla',
                isSelected: selectedIndex == 1,
                onTap: () => onSelected(1),
              ),
              _NavDestination(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                isSelected: selectedIndex == 2,
                onTap: () => onSelected(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavDestination extends StatelessWidget {
  const _NavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final Color iconColor = isSelected ? palette.inverseInk : palette.inkMuted;
    final Color labelColor = isSelected ? palette.ink : palette.inkMuted;
    return Expanded(
      child: Semantics(
        selected: isSelected,
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  width: 48,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? palette.ink : Colors.transparent,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    size: 21,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 240),
                  style:
                      Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w700,
                        color: labelColor,
                      ) ??
                      TextStyle(color: labelColor),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
