import 'package:flutter/material.dart';
import '../../portfolio/app_colors.dart';

/// Soft sky-blue gradient with blurred colour orbs. Glass only looks like
/// glass when there is something colourful behind it.
class GlassBackdrop extends StatelessWidget {
  const GlassBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFD6F0FF), AppColors.background, Colors.white],
            ),
          ),
        ),
        const Positioned(top: -90, right: -70, child: _Orb(260, AppColors.sky)),
        const Positioned(
            top: 300, left: -100, child: _Orb(240, Color(0xFF81D4FA))),
        const Positioned(
            bottom: -80, right: -50, child: _Orb(240, AppColors.skyDeep)),
        child,
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb(this.size, this.color);

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.45), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}