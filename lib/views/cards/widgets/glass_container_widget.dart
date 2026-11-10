import 'dart:ui';

import 'package:flutter/material.dart';

/// Frosted-glass surface: blurs whatever is behind it, adds a translucent
/// white gradient and a hairline highlight border.
///
/// Use for panels, buttons and sheets. NOT used on the 3D-flipping card itself
/// (BackdropFilter inside a Transform is expensive); the card fakes glass with
/// a sheen gradient instead.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.blur = 16,
    this.opacity = 0.35,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double blur;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: opacity + 0.2),
                Colors.white.withValues(alpha: opacity),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          ),
          child: child,
        ),
      ),
    );
  }
}