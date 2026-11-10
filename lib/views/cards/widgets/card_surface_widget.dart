import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../config/theme/constants/text_strings.dart';
import '../../portfolio/app_colors.dart';
import '../models/bank_card_model.dart';
import '../card_theme.dart';

/// Shared body of both card faces: gradient, glossy "glass" sheen, decorative
/// circles, shadow, and the frozen overlay.
class CardSurface extends StatelessWidget {
  const CardSurface({
    super.key,
    required this.kind,
    required this.child,
    this.frozen = false,
  });

  final CardKind kind;
  final Widget child;
  final bool frozen;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(BankCardTheme.radius);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: BankCardTheme.gradientFor(kind),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.skyDeep.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned(top: -50, right: -40, child: _Circle(170, 0.14)),
            const Positioned(bottom: -80, left: -30, child: _Circle(200, 0.08)),
            // Glass sheen
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.28),
                    Colors.white.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.55],
                ),
              ),
            ),
            child,
            if (frozen) const _FrozenOverlay(),
          ],
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle(this.size, this.alpha);
  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      );
}

class _FrozenOverlay extends StatelessWidget {
  const _FrozenOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B2A3D).withValues(alpha: 0.55),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.lock, color: Colors.white, size: 34),
            SizedBox(height: 8),
            Text(
              AppTexts.frozenLabel,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}