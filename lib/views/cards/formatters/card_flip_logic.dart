import 'dart:math' as math;


class CardFlipLogic {
  CardFlipLogic._();

  /// Slightly >1 so a drag a bit shorter than the card width completes a flip.
  static const double sensitivity = 1.3;

  /// Progress-per-second needed for a flick to win over the 50% rule.
  static const double flingProgressVelocity = 1.4;

  /// Which way a drag moves progress. Decided by the first movement so the
  /// card can be flipped by dragging either left or right.
  static double dragSign({required bool startedAtBack, required double firstDx}) {
    if (!firstDx.isFinite || firstDx == 0) return 0;
    return (startedAtBack ? -1.0 : 1.0) * firstDx.sign;
  }

  static double applyDrag({
    required double value,
    required double dx,
    required double width,
    required double sign,
  }) {
    final safe = value.isFinite ? value.clamp(0.0, 1.0).toDouble() : 0.0;
    if (!dx.isFinite || !width.isFinite || width <= 0 || sign == 0) return safe;
    return (safe + sign * sensitivity * dx / width).clamp(0.0, 1.0).toDouble();
  }

  /// 0.0 (front) or 1.0 (back) to animate to once the finger lifts.
  static double resolveTarget({
    required double value,
    required double progressVelocity,
  }) {
    if (!value.isFinite) return 0;
    if (progressVelocity.isFinite) {
      if (progressVelocity >= flingProgressVelocity) return 1;
      if (progressVelocity <= -flingProgressVelocity) return 0;
    }
    return value >= 0.5 ? 1 : 0;
  }

  static double angleFor(double value) =>
      (value.isFinite ? value.clamp(0.0, 1.0).toDouble() : 0.0) * math.pi;

  static bool showsBack(double value) => value > 0.5;
}