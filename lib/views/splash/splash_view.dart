import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../theme/app_palette.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/lottie_assets.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/geometric_pattern.dart';
import '../../widgets/noor_lottie.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool reducedMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      key: const ValueKey<String>('splash-view'),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: GeometricPattern(
              color: palette.ink,
              opacity: 0.035,
              spacing: 54,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: <Widget>[
                  const Spacer(flex: 4),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration:
                        reducedMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (
                      BuildContext context,
                      double value,
                      Widget? child,
                    ) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, (1 - value) * 14),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: <Widget>[
                        const AppLogo(size: 86),
                        const SizedBox(height: 22),
                        Text(
                          'NOOR',
                          style: textTheme.displayLarge?.copyWith(
                            fontFamily: AppTextStyles.displayFamily,
                            fontSize: 50,
                            letterSpacing: 7,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'A quiet place for prayer',
                          style: textTheme.bodyMedium?.copyWith(
                            color: palette.inkMuted,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 5),
                  NoorLottie(
                    asset: LottieAssets.splashOrbit,
                    width: 34,
                    height: 34,
                    color: palette.inkMuted,
                    repeat: true,
                    renderCache: RenderCache.drawingCommands,
                    fallback: _StaticOrbitMark(color: palette.inkMuted),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'PRIVATE BY DESIGN · NO ACCOUNT REQUIRED',
                    textAlign: TextAlign.center,
                    style: textTheme.labelSmall?.copyWith(
                      color: palette.inkMuted,
                      fontSize: 8.5,
                      letterSpacing: 1.25,
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticOrbitMark extends StatelessWidget {
  const _StaticOrbitMark({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 34,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
          ),
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
