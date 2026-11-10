import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../sky_theme.dart';

/// Frosted-glass surface: blurred backdrop, translucent white gradient fill,
/// a thin bright edge and a soft sky-blue shadow.
///
/// It only looks like glass when something colourful sits behind it (the
/// Quick Services panel provides gradient + circles for exactly that).
/// Pass [onTap] to get a ripple that is drawn on top of the glass.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 14,
    this.opacity = 0.42,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final double borderRadius;
  final double blur;

  /// Base fill opacity; the gradient runs from opacity+0.18 to opacity-0.14.
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    Widget content = padding == null
        ? child
        : Padding(padding: padding!, child: child);

    if (onTap != null) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          splashColor: SkyTheme.sky300.withValues(alpha: 0.35),
          highlightColor: SkyTheme.sky200.withValues(alpha: 0.25),
          onTap: onTap,
          child: content,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: SkyTheme.sky500.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: opacity + 0.18),
                  Colors.white.withValues(alpha: opacity - 0.14),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.75),
                width: 1,
              ),
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}