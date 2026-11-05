import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
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
    final Duration motion = AppMotion.resolve(
      context,
      const Duration(milliseconds: 340),
    );
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: palette.line),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: palette.shadow,
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double itemWidth = constraints.maxWidth / 3;
              return SizedBox(
                height: 48,
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: <Widget>[
                    AnimatedPositioned(
                      duration: motion,
                      curve: AppMotion.enter,
                      left: selectedIndex * itemWidth + (itemWidth - 52) / 2,
                      top: 0,
                      width: 52,
                      height: 32,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: palette.ink,
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                    Row(
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
                  ],
                ),
              );
            },
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
    final Duration motion = AppMotion.resolve(
      context,
      const Duration(milliseconds: 240),
    );
    return Expanded(
      child: Semantics(
        selected: isSelected,
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedScale(
                scale: isSelected ? 1.04 : 1,
                duration: motion,
                curve: AppMotion.spring,
                child: SizedBox(
                  width: 52,
                  height: 32,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: motion,
                      switchInCurve: AppMotion.enter,
                      switchOutCurve: AppMotion.exit,
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                      ) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation.drive(
                              Tween<double>(
                                begin: 0.78,
                                end: 1,
                              ).chain(CurveTween(curve: AppMotion.spring)),
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        isSelected ? activeIcon : icon,
                        key: ValueKey<bool>(isSelected),
                        size: 21,
                        color: iconColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: motion,
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
    );
  }
}
