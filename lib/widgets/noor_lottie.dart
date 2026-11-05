import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NoorLottie extends StatelessWidget {
  const NoorLottie({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.color,
    this.opacity = 1,
    this.repeat = false,
    this.reverse = false,
    this.animate = true,
    this.controller,
    this.frameRate = FrameRate.composition,
    this.renderCache,
    this.fallback,
  });

  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final Color? color;
  final double opacity;
  final bool repeat;
  final bool reverse;
  final bool animate;
  final Animation<double>? controller;
  final FrameRate frameRate;
  final RenderCache? renderCache;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final Widget resolvedFallback = fallback ?? const SizedBox.shrink();
    if (MediaQuery.of(context).disableAnimations) {
      return resolvedFallback;
    }

    Widget child = Lottie.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      controller: controller,
      animate: animate,
      repeat: repeat,
      reverse: reverse,
      frameRate: frameRate,
      renderCache: renderCache,
      addRepaintBoundary: true,
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) {
        return resolvedFallback;
      },
    );

    if (color != null) {
      child = ColorFiltered(
        colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
        child: child,
      );
    }
    if (opacity < 1) {
      child = Opacity(opacity: opacity.clamp(0, 1), child: child);
    }

    return ExcludeSemantics(child: IgnorePointer(child: child));
  }
}
