import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/constants/text_strings.dart';
import '../formatters/card_flip_logic.dart';
import '../models/bank_card_model.dart';
import 'card_back_widget.dart';
import 'card_front_widget.dart';
import '../card_theme.dart';
import '../providers/card_ui_provider.dart';

/// The 3D card. Drag (either direction) or tap to flip.
///
/// Why this cannot spin forever / crash:
///  * rotation is an AnimationController value clamped to 0..1 (never an
///    unbounded angle), so there is no modulo wrap-around;
///  * all drag input is validated (NaN/Infinity/zero width are ignored);
///  * on release the card ALWAYS snaps to front or back;
///  * only the AnimatedBuilder subtree rebuilds per frame (no setState);
///  * the controller is disposed with the widget and every async path checks
///    `mounted`.
class FlipCard extends ConsumerStatefulWidget {
  const FlipCard({super.key, required this.card});

  final BankCard card;

  @override
  ConsumerState<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends ConsumerState<FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: BankCardTheme.flipDuration,
  );

  double _target = 0; // 0 front, 1 back, -1 = unknown (mid-drag)
  double _dragSign = 0;
  bool _startedAtBack = false;

  @override
  void initState() {
    super.initState();
    _target = ref.read(cardFlipProvider) ? 1 : 0;
    _controller.value = _target;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(double target) {
    if (!mounted) return;
    // Already heading there (e.g. drag-end animated, then provider echoed).
    if (_target == target && _controller.isAnimating) return;
    _target = target;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = target;
      return;
    }
    _controller.animateTo(target, curve: Curves.easeOutCubic);
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    ref.read(cardFlipProvider.notifier).toggle();
  }

  void _onDragStart(DragStartDetails _) {
    _controller.stop();
    _target = -1;
    _dragSign = 0;
    _startedAtBack = _controller.value > 0.5;
  }

  void _onDragUpdate(DragUpdateDetails d, double width) {
    if (_dragSign == 0) {
      _dragSign = CardFlipLogic.dragSign(
        startedAtBack: _startedAtBack,
        firstDx: d.delta.dx,
      );
    }
    _controller.value = CardFlipLogic.applyDrag(
      value: _controller.value,
      dx: d.delta.dx,
      width: width,
      sign: _dragSign,
    );
  }

  void _settle({double velocityX = 0, double width = 1}) {
    final progressVelocity =
        (width > 0 && velocityX.isFinite) ? _dragSign * velocityX / width : 0.0;
    final target = CardFlipLogic.resolveTarget(
      value: _controller.value,
      progressVelocity: progressVelocity,
    );
    _dragSign = 0;
    _animateTo(target);
    ref.read(cardFlipProvider.notifier).set(target == 1);
  }

  @override
  Widget build(BuildContext context) {
    // Buttons ("Show CVV") drive the card through this provider.
    ref.listen<bool>(
      cardFlipProvider,
      (_, showBack) => _animateTo(showBack ? 1 : 0),
    );

    final card = widget.card;
    final front = CardFront(card: card);
    final back = CardBack(card: card);

    return Semantics(
      container: true,
      button: true,
      label: '${card.label}, ${AppTexts.endingIn} ${card.last4}',
      hint: AppTexts.flipHint,
      onTap: _toggle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width =
              constraints.maxWidth.isFinite ? constraints.maxWidth : 340.0;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: (d) => _onDragUpdate(d, width),
            onHorizontalDragEnd: (d) => _settle(
              velocityX: d.velocity.pixelsPerSecond.dx,
              width: width,
            ),
            onHorizontalDragCancel: _settle,
            child: RepaintBoundary(
              child: AspectRatio(
                aspectRatio: BankCardTheme.aspectRatio,
                // Faces are designed at one size and uniformly scaled, so the
                // card looks identical on small phones and tablets.
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: BankCardTheme.designWidth,
                    height: BankCardTheme.designWidth /
                        BankCardTheme.aspectRatio,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        final v = _controller.value;
                        final showBack = CardFlipLogic.showsBack(v);
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0012)
                            ..rotateY(CardFlipLogic.angleFor(v)),
                          child: showBack
                              // Counter-rotate so the back isn't mirrored.
                              ? Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(math.pi),
                                  child: back,
                                )
                              : front,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}