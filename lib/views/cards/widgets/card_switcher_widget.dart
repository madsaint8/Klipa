import 'package:flutter/material.dart';
import '../card_theme.dart';

/// One transition used everywhere (card swap, settings swap, state swap) so
/// the whole screen moves consistently: fade + tiny slide + tiny scale, with
/// animated height so layout never jumps. Respects "reduce motion".
///
/// The [child] MUST have a distinct Key for the transition to run.
class CardSwitcher extends StatelessWidget {
  const CardSwitcher({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : BankCardTheme.switchDuration;

    return AnimatedSize(
      duration: duration,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(animation),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.97, end: 1).animate(animation),
              child: child,
            ),
          ),
        ),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topCenter,
          children: [...previous, if (current != null) current],
        ),
        child: child,
      ),
    );
  }
}